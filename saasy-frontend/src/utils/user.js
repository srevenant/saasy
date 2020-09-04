import config from 'constants/config'
import moment from 'moment'

export function defaultUser() {
  return {
    id: '',
    settings: {},
    handle: '',
    name: '',
    verified: false,
    avatar: { url: '' },
    displayEmail: '',
    emails: [],
    data: [],
    ...normalizeUserParam('data', []),
    ...normalizeUserParam('tags', []),
    subscriptions: [],
    unreadThreads: 0,
    authStatus: 'unknown',
    access_token: undefined,
    access_token_expires: 0,
    validation_token: undefined,
    can: (x) => false,
    is: (x) => false,
    allows: (x, y) => false,
    isIdentified: false,
    isAuthed: false
  }
}

// input 'key' and value, always return new dictionary values that
// are to be merged into parent dictionary
export function normalizeUserParam(key, value) {
  switch (key) {
    case 'data':
      // TODO:
      // * switch address to 'location' or 'locale'
      // * switch profile to ... something else
      const data = {
        dataTypes: {
          tags: { value: {} },
          profile: { value: {} },
          address: { value: {} },
          toggles: { value: {} },
          roles: { value: {} },
          skills: { value: {} },
          ...(value || []).reduce((a, d) => {
            a[d.type] = d
            return a
          }, {})
        }
      }
      data.toggles = data.dataTypes.toggles.value
      return data

    case 'tags':
      return {
        tags: value,
        tagsD: (value || []).reduce((acc, tag) => {
          const current = acc[tag.type] || []
          acc[tag.type] = current.concat(tag.tag)
          return acc
        }, {})
      }

    case 'avatar':
      if (value.path) {
        return { avatar: { ...value, url: config.imgurl + value.path } }
      }
      return { avatar: { ...value } }

    case 'emails':
      if (value && value.length > 0) {
        const vemails = value.filter((e) => e.verified)
        let verified = false
        let displayEmail = ''
        if (vemails.length > 0) {
          verified = true
          displayEmail = vemails[0].address
        } else {
          displayEmail = value[0].address
        }
        return { verified, displayEmail }
      }
      return {}

    default:
      return { [key]: value }
  }
}

// this is intentionally non-immutable, which is only done for performance
// on high level things like a list of a lot of users.  Don't put a lot into
// this -- most things should go into normalizeUser and create a new instance
export function normalizePublicUser(user) {
  if (user._normal) return user

  user._normal = true
  user.allows = (actor, action) => {
    return actor.id === user.id || actor.is('superadmin')
  }

  Object.assign(user, normalizeUserParam('avatar', user.avatar))

  Object.assign(user, normalizeUserParam('tags', user.tags))

  Object.assign(user, normalizeUserParam('data', user.data))

  user._last = moment(user.lastSeen).unix()

  return user
}

// this always returns a new object
export function normalizeUser(indata, real) {
  let roles = new Set()
  let actions = new Set()
  if (indata.access) {
    if (indata.access.roles) roles = new Set(indata.access.roles)
    if (indata.access.actions) actions = new Set(indata.access.actions)
  }

  const authStatus = (indata ? indata.authStatus : undefined) || 'unknown'

  const user = {
    ...defaultUser(),
    ...indata,
    roles,
    actions,
    authStatus,
    ...normalizeUserParam('emails', indata.emails),
    can: (action) => actions.has(action),
    is: (role) => roles.has(role),
    isIdentified: authStatus !== 'unknown',
    isAuthed: ['authed', 'multi-authed'].includes(authStatus),
    _real: real || false
  }

  return normalizePublicUser(user)
}

// export function normalizeTags(tags) {
//   return tags.reduce((acc, tag) => {
//     const current = acc[tag.type] || []
//     acc[tag.type] = current.concat(tag.tag)
//     return acc
//   }, {})
// }
