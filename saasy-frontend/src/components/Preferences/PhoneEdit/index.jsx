import React, { useState } from 'react'
import { InputInline } from 'tools/InputInline'

function EditPhone({ makeChange, phones, className = 'mv2' }) {
  return (
    <>
      <div className={className}>
        <label className="f6 b db mb2 mt3 heading">Phone</label>
      </div>
      <div className="w-100 ba b--theme-faint br2 mb2 input noedit pa2">
        {phones.map((phone) => (
          <ShowPhone
            key={phone.id}
            phone={phone}
            makeChange={makeChange}
            phones={phones}
          />
        ))}
        <AddPhone makeChange={makeChange} />
      </div>
    </>
  )
}

function ShowPhone({ phone, makeChange, phones }) {
  return (
    <div
      key={phone.id}
      className="hover-hilight flex justify-between items-center mb2"
    >
      {phone.number}
      {phones.length > 1 ? (
        <i
          className="fas fa-trash hover pa1 br2 pointer f7 hover-hilight"
          onClick={() => {
            makeChange({ rmphone: phone.id })
          }}
        />
      ) : null}
    </div>
  )
}

function AddPhone({ makeChange }) {
  const [adding, setAdding] = useState(false)
  const [phone, setPhone] = useState('')
  const [msg, setMsg] = useState(null)

  if (adding) {
    return (
      <>
        <div className="flex items-center">
          <InputInline
            valState={[phone, setPhone]}
            onSave={() => {}}
            token="phone"
            format="(###) ###-####"
            mask="_"
            icons={false}
            numberFormatter={true}
          />
          <button
            className="button pa2 ml2 ph4"
            onClick={() => {
              makeChange({ phone: phone }, (result) => {
                if (result.success) {
                  setAdding(false)
                  setPhone('')
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
      className="button f6 pa2 mb0 mt1 ph4 tl"
      onClick={() => setAdding(true)}
    >
      <i className="fas fa-plus mr2" />
      Add Phone
    </button>
  )
}

export default EditPhone
