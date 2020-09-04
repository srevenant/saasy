// @ts-nocheck
// ^- nocheck added because typescript is complaining about interface things
//    from react-google-login which are actually not issues, and being in an
//    external library, we also cannot change
import React, { useContext } from 'react'
import GoogleLogin from 'react-google-login'
import Store from '../../store'
import { AUTHX_ACTIONS } from '../../utils/authx'

// xref for others: https://medium.com/@alexanderleon/implement-social-authentication-with-react-restful-api-9b44f4714fa

function handleSuccess({ profileObj, tokenObj }, next) {
  next({ type: 'google', profile: profileObj, authResponse: tokenObj })
}

// note: react-google-login is not supporting the ability to restyle the base component,
// it is injecting style={} of its own devising, and is ignoring style arguments sent.
// TODO: fork or find another lib.  For now, this works, but is ugly.
//
// tried: react-google-authorize, and while it behaves very similarly, it only
//    returns the auth token, and not the profile metadata
//
function GoogleAuth({ config, onSuccess, onFailure }) {
  const [, dispatch] = useContext(Store)

  return (
    <GoogleLogin
      clientId={config.federated.google.appId}
      onSuccess={(auth) => handleSuccess(auth, onSuccess)}
      onFailure={() => onFailure()}
      onRequest={() => {
        dispatch({ type: AUTHX_ACTIONS.SIGNING_IN })
      }}
      cookiePolicy={'single_host_origin'}
      className="button auth-signin"
      icon={false}
    >
      <div className="flex align-items-center text-center">
        <div className="fab fa-google f5"></div>
        <div className="label text-center" style={{ width: '100px' }}>
          Google
        </div>
      </div>
    </GoogleLogin>
  )
}

export default GoogleAuth
