import React, { useState, useContext } from 'react'
import {
  CHANGE_PASSWORD,
  REQUEST_PASSWORD_RESET,
  MY_FACTORS
} from 'constants/Person'
import { useMutation, useQuery } from 'react-apollo'
import { useHistory } from 'react-router-dom'
import Store from 'store'

////////////////////////////////////////////////////////////////////////////////
function Boxed({ children }) {
  return <div className="ma0 ma4-m ma5-l pa3 pa4-ns theme-frame">{children}</div>
}

function EmailInput(props) {
  const {
    value: [email, setEmail],
    button
  } = props
  return (
    <>
      <div className="mt4 mb3">
        <label>Your Email Address</label>
      </div>
      <div className="mt2">
        <input
          className="w-100"
          value={email}
          placeholder="Email Address"
          onChange={(ev) => setEmail(ev.target.value)}
        />
        {button}
      </div>
    </>
  )
}

function RequestReset(props) {
  const [email, setEmail] = useState('')
  const [msg, setMsg] = useState(<></>)
  const [requestReset] = useMutation(REQUEST_PASSWORD_RESET)

  return (
    <Boxed>
      <div className="">
        If you have forgotten your password or you are signed in with Federated
        Identity (i.e. google or other), you can request a password reset. This
        will send you an email with a reset code and instructions on what to do
        next.
      </div>
      <EmailInput
        value={[email, setEmail]}
        button={
          <>
            <button
              className="button mt2"
              onClick={() => {
                if (email.length > 0 && email.includes('@')) {
                  requestReset({
                    variables: { email: email },
                    update: (cache, result) => {
                      setMsg(
                        <>
                          Your request is submitted. If this email is in our
                          system, you will receive a message in a few minutes with
                          further instructions.
                        </>
                      )
                    }
                  })
                } else {
                  setMsg(<>Please provide a valid email address</>)
                }
              }}
            >
              Request Reset
            </button>
            <div className="mt2 i">{msg}</div>
          </>
        }
      />
    </Boxed>
  )
}

function ResetButton({ children }) {
  const history = useHistory()
  return (
    <button
      className="button-clear-light i ma0 pa0"
      onClick={() => {
        history.push('/pwreset?request=yes')
      }}
    >
      {children}
    </button>
  )
}

function PasswordReset() {
  const [{ state }] = useContext(Store)
  const args = new URLSearchParams(useHistory().location.search)

  if (args.get('request') === 'yes') {
    return <RequestReset args={args} />
  } else {
    return (
      <Boxed>
        <div className="">
          If you have forgotten your password or you are signed in with Federated
          Identity (i.e. google or other), you can request a password reset. This
          will send you an email with a reset code, which you can use here to
          change your password.
          {state ? null : (
            <div className="mv3">
              <ResetButton>Request Password Reset Code</ResetButton>
            </div>
          )}
        </div>
        <ChangePassword
          inputCode={args.get('code')}
          inputEmail={args.get('email')}
        />
      </Boxed>
    )
  }
}

export function ChangePassword({ inputCode, inputEmail, ...more }) {
  const [state] = useContext(Store)
  const [code, setCode] = useState(inputCode || '')
  const [pass1, setPass1] = useState('')
  const [pass2, setPass2] = useState('')
  const [email, setEmail] = useState(inputEmail || '')
  const [showCurrent, setShowCurrent] = useState(!!inputCode)
  const [showNew, setShowNew] = useState(false)
  const [msg, setMsg] = useState(<></>)
  const [changePassword] = useMutation(CHANGE_PASSWORD)
  const [requestReset] = useMutation(REQUEST_PASSWORD_RESET)
  const { data } = useQuery(MY_FACTORS)
  let primaryEmail
  if (state) {
    const pr = state.user
    pr.emails.forEach((email) => {
      if (email.primary) {
        primaryEmail = email
      }
    })
    if (!primaryEmail && pr.emails.length) {
      primaryEmail = pr.emails[0]
    }
  }
  const matching = () => {
    if (pass1 !== pass2) {
      return false
    }
    return true
  }
  const isGood = () => {
    if (
      matching() &&
      pass1 &&
      pass1.length > 8 &&
      pass1.match(/[^a-z0-9]/) &&
      pass1.match(/[0-9]/)
    ) {
      return true
    }
    return false
  }
  const change = (hook, ev) => {
    if (msg) {
      setMsg(null)
    }
    hook(ev.target.value.trim())
  }
  let factors = {}
  if (data && data.self.factors) {
    factors = data.self.factors.reduce((acc, factor) => {
      acc[factor.type] = true
      return acc
    }, {})
  }
  return (
    <>
      {state.user.isIdentified ? (
        <>
          {factors.federated && !factors.password ? (
            <div className="">
              You are signed in with Federated authentication, and have not set a
              password before. In order to set a password, you will need to
              request a Password Reset Code (see link below).
            </div>
          ) : null}
        </>
      ) : (
        <EmailInput value={[email, setEmail]} />
      )}
      <div
        onBlur={(ev) => {
          ev.stopPropagation()
          setShowCurrent(false)
        }}
      >
        <div className="mt3">
          <label>
            Current Password or Reset Code
            <i
              className="fas fa-eye ml3 hover pointer"
              onClick={() => setShowCurrent(!showCurrent)}
            />
          </label>
        </div>
        <div className="mt2 flex items-center">
          <input
            className="w-100"
            type={showCurrent ? 'text' : 'password'}
            name="current"
            value={code}
            placeholder="Current Password or Reset Code"
            onChange={(ev) => change(setCode, ev)}
          />
        </div>
        <div className="f7 mt2 tr">
          {state.user.isAuthed && primaryEmail ? (
            <span
              className="button-clear-light i pa1 br2"
              onClick={() => {
                requestReset({
                  variables: { email: primaryEmail.address },
                  update: (cache, result) => {
                    setMsg(
                      <div className="fo-text-white i">
                        Your request is submitted. Check your email for further
                        instructions.
                      </div>
                    )
                  }
                })
              }}
            >
              Request Reset Code
            </span>
          ) : null}
        </div>
      </div>

      <div
        className="mt3"
        onBlur={(ev) => {
          ev.stopPropagation()
          setShowNew(false)
        }}
      >
        <label>
          New Password
          <i
            className="fas fa-eye ml3 hover pointer"
            onClick={() => setShowNew(!showNew)}
          />
        </label>
        <div className="mt2">
          Passwords must be at least 8 characters long, and contain a digit and a
          non-alphabetic character.
        </div>
        <div className="mt2">
          <input
            name="password"
            type={showNew ? 'text' : 'password'}
            className="w-100"
            value={pass1}
            placeholder="New Password"
            onChange={(ev) => change(setPass1, ev)}
          />
        </div>
        <div className="mt2">
          <input
            name="password2"
            type={showNew ? 'text' : 'password'}
            className="w-100"
            value={pass2}
            placeholder="New Password (again)"
            onChange={(ev) => change(setPass2, ev)}
          />
        </div>
        <div className="mt3 red">
          {pass1.length > 1 ? (
            isGood() ? (
              <button
                onClick={() => {
                  changePassword({
                    variables: {
                      email: email,
                      current: code,
                      new: pass1
                    },
                    update: (cache, { data: { changePassword } }) => {
                      if (changePassword.success) {
                        setCode('')
                        setEmail('')
                        setPass1('')
                        setPass2('')
                        if (state.user.isIdentified) {
                          setMsg(<div className="green">Password updated!</div>)
                        } else {
                          setMsg(
                            <div className="green">
                              Password updated! You can now{' '}
                              <a href="/#/signon">
                                <b>Sign In</b>
                              </a>
                            </div>
                          )
                        }
                      } else {
                        setMsg(<>{changePassword.reason}</>)
                      }
                    }
                  })
                }}
              >
                Change
              </button>
            ) : code.length === 0 ? (
              <>Current Password or One-time Code is missing</>
            ) : pass1.length < 8 ? (
              <>Password is not long enough (8 characters)</>
            ) : matching() ? (
              <>Password does not include a special character and digit</>
            ) : !state.user.isIdentified && !email.length ? (
              <>Missing Email</>
            ) : (
              <>Passwords do not match</>
            )
          ) : null}
          {msg ? <div className="mt3">{msg}</div> : null}
        </div>
      </div>
    </>
  )
}

export default PasswordReset
