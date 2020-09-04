import React, { useState, useEffect } from 'react'
import { useHistory } from 'react-router-dom'
import Toggle from 'tools/Toggle'
import Modal from 'tools/Modal'
import EmailEdit from '../EmailEdit'
import PhoneEdit from '../PhoneEdit'
import ThemeToggle from '../ThemeToggle'

function Settings(props) {
  // break out so it is easy to pass along
  const { makeChange, user } = props
  const history = useHistory()
  const args = new URLSearchParams(history.location.search)
  const [showOkay, setShowOkay] = useState(args.get('vok'))

  return (
    <>
      <div className="theme-frame theme-bg-flat w-100 mr1-l">
        <div className="pv1 pv2-ns ph2 ph3-l tl theme-bg-accent br2 w-100 f6 b mr2 flex justify-between ttu">
          <div>Settings and Contact Information</div>
        </div>
        <div className="ph1 ph2-m ph3-l w-100 ba b--transparent pb3">
          <PhoneEdit
            makeChange={makeChange}
            phones={user.phones}
            className="mt3 mb2"
          />
          <EmailEdit
            makeChange={makeChange}
            emails={user.emails}
            className="mt3 mb2"
          />
          <FederatedAuthPrefs {...props} className="mt3 mb2" />
          <ThemeToggle {...props} className="mt3 mb2" />
        </div>
      </div>
      {showOkay ? (
        <Modal viewState={[showOkay, setShowOkay]} width="fw-50">
          <div
            className="flex-center flex-column fo-text-white"
            style={{ minHeight: '75vh' }}
          >
            <div>Email Verified!</div>
            <div className="mt3">{showOkay}</div>
            <button
              onClick={() => {
                setShowOkay('')
                history.push(history.location.path)
              }}
              className="mt3"
            >
              Okay
            </button>
          </div>
        </Modal>
      ) : null}
    </>
  )
}

////////////////////////////////////////////////////////////////////////////////
function FederatedAuthPrefs({ settings, makeChange, className }) {
  const [googleAuth, setGoogleAuth] = useState(false)
  const authGoog = settings.authAllowed && settings.authAllowed.google

  useEffect(() => {
    setGoogleAuth(authGoog)
  }, [authGoog])

  return (
    <>
      <div className={className}>
        <label className="f6 b db mb2 mt3 heading">
          Federated Authentication
        </label>
      </div>
      <div className="mv2 flex items-center pl2">
        <Toggle
          onChange={() => {
            const value = !googleAuth
            setGoogleAuth(value)
            settings.authAllowed.google = value
            makeChange({ settings: JSON.stringify(settings) })
          }}
          value={googleAuth}
        >
          Google Authentication (using the above email)
        </Toggle>
      </div>
    </>
  )
}

export default Settings
