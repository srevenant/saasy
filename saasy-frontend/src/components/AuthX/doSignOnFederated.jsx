import { authDebug, startValidate } from '../../utils/authx'

export function doSignOnFederated({
  state,
  status,
  type,
  profile,
  authResponse,
  dispatch
}) {
  authDebug(1, '[AuthX].doSignOnFederated()')
  return startValidate({
    state,
    status,
    vars: {
      type: type,
      data: { profile: profile, auth: authResponse }
    },
    dispatch
  })
}
