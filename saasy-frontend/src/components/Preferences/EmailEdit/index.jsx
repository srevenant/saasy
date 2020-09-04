import React, { useState } from 'react'
import { inputClasses } from 'tools/InputInline'

function EditEmail({ makeChange, emails, className = 'mv2' }) {
  return (
    <>
      <div className={className}>
        <label className="f6 b db mb2 mt3 heading">Email</label>
      </div>
      <div className="w-100 ba b--theme-faint br2 mb2 input noedit pa2">
        {emails.map((email) => (
          <ShowEmail
            key={email.id}
            email={email}
            makeChange={makeChange}
            emails={emails}
          />
        ))}
        <AddEmail makeChange={makeChange} />
      </div>
    </>
  )
}

function ShowEmail({ email, makeChange, emails }) {
  const [check, setCheck] = useState(false)
  return (
    <div
      key={email.id}
      className="hover-hilight flex justify-between items-center mb2"
    >
      {email.address}
      <div className={`${email.verified ? 'green' : 'red'} ml2 f7 mr-auto`}>
        {email.verified ? (
          'verified'
        ) : (
          <>
            <button
              className="button-clear-light pa0 ph2"
              onClick={() => {
                makeChange({ verifyemail: email.id })
                setCheck(true)
              }}
            >
              resend verify email
            </button>
            {check ? <i className="ml2 fas fa-check green" /> : null}
          </>
        )}
      </div>
      {emails.length > 1 ? (
        <i
          className="fas fa-trash hover-hilight pa1 br0 pointer f7"
          onClick={() => {
            makeChange({ rmemail: email.id })
          }}
        />
      ) : null}
    </div>
  )
}

function AddEmail({ makeChange }) {
  const [adding, setAdding] = useState(false)
  const [newEmail, setNewEmail] = useState('')
  const [msg, setMsg] = useState(null)

  if (adding) {
    return (
      <>
        <div className="flex items-center">
          <input
            className={`${inputClasses} w-100`}
            value={newEmail}
            autoFocus={true}
            placeholder="New Email Address"
            onChange={(ev) => {
              setNewEmail(ev.target.value.trim())
            }}
          />
          <button
            className="button pa2 ml2 ph4"
            onClick={() => {
              makeChange({ email: newEmail }, (result) => {
                if (result.success) {
                  setAdding(false)
                  setNewEmail('')
                  setMsg(null)
                } else {
                  setMsg(<div className="red mt2">{result.reason}</div>)
                }
              })
            }}
          >
            Add
          </button>
        </div>
        {msg}
      </>
    )
  }
  return (
    <button
      className="button-grayblue f6 pa2 mb0 mt1 ph4 tl"
      onClick={() => setAdding(true)}
    >
      <i className="fas fa-plus mr2" />
      Add Email
    </button>
  )
}

export default EditEmail
