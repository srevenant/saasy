import React, { useReducer, createContext } from 'react'
import { normalizeUser, normalizeUserParam } from 'utils/user'

export const ACTIONS = {
  SET_PERSON: 'SET_PERSON',
  SET_PERSON_TAGS: 'SET_PERSON_TAGS',
  SET_PERSON_PARAM: 'SET_PERSON_PARAM',
  SET_FORM_PARAM: 'SET_FORM_PARAM',
  MERGE: 'MERGE'
  // SET_SORT: 'SET_SORT',
  // UPSERT_ONE: 'UPSERT_ONE',
  // DROP_ONE: 'DROP_ONE',
  // SET_LIST: 'SET_LIST'
}

// `person` is for normalized data as returned from server
// `form` is for form handling in an easier to handle manner (one level deep)
function defaultProfile() {
  return {
    person: {},
    form: {},
    error: ''
  }
}

function reducer(state, action) {
  switch (action.type) {
    case ACTIONS.SET_PERSON:
      const sp_person = normalizeUser(action.value, true)
      return {
        ...state,
        person: sp_person,
        form: {
          name: sp_person.name,
          handle: sp_person.handle,
          phone: sp_person.displayPhone || '',
          desc: sp_person.dataTypes.profile.value.desc || '',
          city: sp_person.dataTypes.address.value.city || '',
          state: sp_person.dataTypes.address.value.state || '',
          interest: sp_person.dataTypes.profile.value.interest || ''
        }
      }

    case ACTIONS.SET_PERSON_PARAM:
      return {
        ...state,
        person: { ...state.person, ...normalizeUserParam(...action.value) }
      }

    case ACTIONS.SET_FORM_PARAM:
      return { ...state, form: { ...state.form, ...action.value } }

    case ACTIONS.MERGE:
      return { ...state, ...action.value }

    default:
      throw new Error(`no such action.type: ${action.type}!`)
  }
}

export const ProfileContext = createContext(null)

export function ProfileProvider({ children }) {
  const [state, dispatch] = useReducer(reducer, {
    ...defaultProfile(),
    person: normalizeUser({})
  })
  return (
    <ProfileContext.Provider value={[state, dispatch]}>
      {children}
    </ProfileContext.Provider>
  )
}

export default ProfileContext
