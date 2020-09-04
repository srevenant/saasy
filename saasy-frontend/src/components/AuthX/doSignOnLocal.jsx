import {
  authError,
  startValidate,
  authDebug,
  AUTHX_ACTIONS
} from '../../utils/authx/'

export function doSignOnLocal({
  signup,
  handle,
  password,
  state,
  status,
  dispatch
}) {
  authDebug('[AuthX].doSignOnLocal()', '')

  dispatch({ type: AUTHX_ACTIONS.SIGNING_IN })
  let vars = {
    signup: signup === 'signup',
    factor: 'email', // in the future: let people choose factors to auth with
    handle: handle.value.trim(),
    password: password.value.trim(),
    email: ''
  }

  if (signup) {
    vars.email = vars.handle
  }

  if (vars.handle.length === 0) {
    authError({ dispatch, msg: 'Please provide an email address!' })
    return Promise.resolve({ aborted: true })
  }
  if (vars.password.length === 0) {
    authError({ dispatch, msg: 'Please provide a password!' })
    return Promise.resolve({ aborted: true })
  }

  return startValidate({ state, status, vars, dispatch })
}
