import React, { useContext, useEffect } from 'react'
import { useHistory } from 'react-router-dom'
import { TENANT } from 'constants/AuthX'
import SignForm from './SignForm'
import { LoadingOverlay } from 'tools/Handlers'
import Store, { usePage } from 'store'
import { AUTHX_ACTIONS } from 'utils/authx'

////////////////////////////////////////////////////////////////////////////////
export function Login({ signout }) {
  usePage({ name: 'AuthX:Signon', background: 'image' })
  const history = useHistory()
  const [state, dispatch] = useContext(Store)

  useEffect(() => {
    if (signout) {
      dispatch({ type: AUTHX_ACTIONS.SIGN_OUT })
      history.push('/signon')
    }

    const path7 = history.location.pathname.substring(0, 7)
    if (path7 === '/signou') {
      dispatch({ type: AUTHX_ACTIONS.SIGN_OUT })
      history.push('/signon')
    } else {
      if (path7 === '/signon') {
        const { user } = state
        if (user.isAuthed) {
          if (user.settings.newUser) {
            history.push('/prefs/profile')
          } else {
            history.push('/')
          }
        }
      }
    }
  }, [history, state.user.isAuthed, signout, dispatch, state])

  return (
    <>
      <div className="mb6 mb0-ns">
        {TENANT.heading}
        {state.user.handshaking ? <LoadingOverlay /> : null}
        <SignForm />
      </div>
    </>
  )
}

export default Login
