import React, { useState, useContext } from 'react'
import { doSignOnFederated } from './doSignOnFederated'
import GoogleAuth from './GoogleAuth'
import StatusBox from './StatusBox'
import Store from '../../store'
import { AUTHX_ACTIONS } from '../../utils/authx'

export function SignOnFederated({ tenant, className = '' }) {
  const [state, dispatch] = useContext(Store)
  const [status, setStatus] = useState('')

  if (!tenant.federated.google.enabled)
    return null

  return (
    <>
      <div className="hrstrike pt3 pb3">
        <div className="f7 gray">or</div>
      </div>
      <div className="flex justify-center items-center">
        <GoogleAuth
          config={tenant}
          onSuccess={({ type, profile, authResponse }) =>
            doSignOnFederated({
              state,
              status: { status, setStatus },
              type,
              profile,
              authResponse,
              dispatch
            })
          }
          onFailure={(e) => {
            dispatch({ type: AUTHX_ACTIONS.SIGN_OUT })
          }}
        />
      </div>
      <StatusBox message={status} />
    </>
  )
}
export default SignOnFederated
