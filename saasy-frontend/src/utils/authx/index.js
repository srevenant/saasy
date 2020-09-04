import jwt from 'jsonwebtoken'
import { v4 as uuid } from 'uuid'
import { readableError } from 'tools/Handlers'
import { safeStoreGet, safeStorePut, safeStoreDrop } from './safeLocalStore'
import config from 'constants/config'
import { VALIDATION_KEY } from 'constants/AuthX'
import axios from 'axios'
// import debug from '../debug'
// // level 0 is nothing, higher levels are more verbosity
// const DEBUG_LEVEL = 1
// export function authDebug(level, message, data) {
//   if (level <= DEBUG_LEVEL) {
//     debug(message, data)
//   }
// }
export const authDebug = (a, b, c) => {}

export const AUTHX_ACTIONS = {
  SIGNING_IN: 'AUTHX_ACTIONS_SIGNING_IN',
  SIGN_OUT: 'AUTHX_ACTIONS_SIGN_OUT',
  ERROR: 'AUTHX_ACTIONS_ERROR',
  ERROR_CLEAR: 'AUTHX_ACTIONS_ERROR_CLEAR',
  SIGNED_IN: 'AUTHX_ACTIONS_SIGNED_IN',
  REFRESH_TOKEN: 'AUTHX_ACTIONS_REFRESH_TOKEN'
}

export const initialState = {
  targetAuthed: false, // what is our desired state - authenticated or not?
  handshaking: false, // are we in the middle of a signin sequence? - used by the AuthX frontend
  isAuthN: false, // have we been authenticated?
  error: undefined,
  refresh: false // trigger a token refresh
}

export function authXinitialState() {
  const hasValKey = !!getValidationKey()
  return {
    ...initialState,
    targetAuthed: hasValKey,
    refresh: hasValKey
  }
}

////////////////////////////////////////////////////////////////////////////////
// mutable global -- not ideal, but we have a tough challenge
const defaultAccessToken = { token: '', expires: 0, valid: false, claims: {} }
let ACCESS_TOKEN = { ...defaultAccessToken }

export function getAccessToken(dispatch) {
  authDebug(5, '[utils/authx] getAccessToken()', `valid=${ACCESS_TOKEN.valid}`)
  if (ACCESS_TOKEN.valid && Date.now() > ACCESS_TOKEN.expires) {
    authDebug(3, '[utils/authx] getAccessToken()', `expired - removing`)
    setAccessToken(null)
    dispatch({ type: AUTHX_ACTIONS.REFRESH_TOKEN, value: true })
  }
  return ACCESS_TOKEN
}

export function setAccessToken(token) {
  ACCESS_TOKEN = validAccessToken(token)
  authDebug(3, '[utils/authx] setAccessToken()', `valid=${ACCESS_TOKEN.valid}`)
}

export function dropAccessToken() {
  authDebug(3, '[utils/authx] dropAccessToken()', '')
  ACCESS_TOKEN = { ...defaultAccessToken }
}

function validAccessToken(token) {
  authDebug(5, '[utils/authx] validAccessToken()', token)
  if (!token) {
    return { ...defaultAccessToken }
  }

  const claims = jwt.decode(token)
  authDebug(4, '[utils/authx] token claims', [claims, token])
  if (Date.now() / 1000 < claims.exp) {
    return { claims, token, expires: claims.exp * 1000, valid: true }
  }
  return { ...defaultAccessToken }
}

////////////////////////////////////////////////////////////////////////////////
export function getValidationKey() {
  // authDebug(3, "[utils/authx] getValidationKey()", '')
  const key = safeStoreGet(VALIDATION_KEY)
  authDebug(3, '[utils/authx] getValidationKey() key => ', key)
  return key
}

export function setValidationKey(key) {
  authDebug(3, '[utils/authx] setValidationKey()', key)
  safeStorePut(VALIDATION_KEY, key)
}

export function dropValidationKey() {
  authDebug(3, '[utils/authx] dropValidationKey()', '')
  safeStoreDrop(VALIDATION_KEY)
}

////////////////////////////////////////////////////////////////////////////////
// Try to get/refresh token and then signInUser or SIGNOUT
export function refreshToken(dispatch) {
  authDebug(3, '[utils/authx] refreshToken()', '')
  const { valid } = getAccessToken()
  if (!valid) {
    authDebug(1, '[utils/authx] refreshToken()', 'not valid -> REFRESHING')
    const validation_token = getValidationKey()
    if (validation_token) {
      const refresh = genRefreshToken()
      if (refresh) {
        return authRequest('refresh', {
          body: JSON.stringify({
            client_assertion_type:
              'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
            client_assertion: refresh
          })
        }).then((result) => {
          const { access_token } = result
          authDebug(
            2,
            '[utils/authx] refreshToken():',
            `REFRESHED=${!!access_token}`
          )
          if (access_token) {
            setAccessToken(access_token)
            dispatch({ type: AUTHX_ACTIONS.SIGNED_IN })
          } else {
            dispatch({ type: AUTHX_ACTIONS.SIGN_OUT })
          }
          return result
        })
      }
    } else {
      dispatch({ type: AUTHX_ACTIONS.SIGN_OUT })
    }
  }
  authDebug(5, '[utils/authx] refreshToken()', 'unable to refresh')
  return Promise.resolve(new Error('unable to refresh token'))
}

export function genRefreshToken() {
  authDebug(5, '[utils/authx] genRefreshToken()')
  const validation_token = safeStoreGet(VALIDATION_KEY)
  if (validation_token) {
    const { secret, subject, audience } = validation_token
    return jwt.sign(
      {
        jti: uuid(),
        sub: subject,
        aud: audience
      },
      secret,
      { expiresIn: 10 * 60 }
    )
  } else {
    return false
  }
}

////////////////////////////////////////////////////////////////////////////////
// handlers from the various signOn interfaces
export function startValidate({ state, vars, status, dispatch }) {
  authDropStates()
  authDebug(1, '[utils/authx] startValidate()')
  return authRequest('signon', {
    body: JSON.stringify(vars)
  })
    .then((data) => handleValidate({ state, status, data, dispatch }))
    .catch((error) => authError({ dispatch, msg: readableError(error) }))
}

function handleValidate({ state, status, data, dispatch }) {
  authDebug(2, '[utils/authx] handleValidate() data=', data)
  if (data.aud && data.sec && data.sub) {
    let token = {
      audience: data.aud,
      secret: data.sec,
      subject: data.sub
    }
    setValidationKey(token)
    return refreshToken(dispatch)
  } else if (data.reason) {
    authError({ dispatch, msg: readableError(data.reason) })
  } else {
    authError({
      dispatch,
      msg:
        'response received from backend with no genRefreshToken token? cannot continue'
    })
  }
}

////////////////////////////////////////////////////////////////////////////////
export function authDropStates() {
  authDebug(1, '[utils/authx] authDropStates()')
  dropAccessToken()
  dropValidationKey()
}

export function authRequest(path, opts) {
  authDebug(3, '[utils/authx] authRequest():', `{api}/${path}`)
  if (!opts.headers) {
    opts.headers = {}
  }
  if (!opts.headers['Content-Type']) {
    opts.headers['Content-Type'] = 'application/json'
  }
  return axios
    .post(config.baseurl + config.authapi + path, opts.body, {
      headers: opts.headers,
      withCredentials: true
    })
    .then((res) => {
      return res.data
    })
}

export function authError({ dispatch, msg }) {
  authDebug(3, '[utils/authx] authError() msg=', msg)
  dispatch({ type: AUTHX_ACTIONS.ERROR, value: msg })
}
