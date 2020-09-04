import React from 'react'
import Modal from 'tools/Modal'

function Confirm({ onConfirm, children = undefined, title = '', viewState }) {
  return (
    <Modal
      viewState={viewState}
      width="fw-50"
      className="theme-frame theme-bg-flat pa4"
    >
      <div className="f3 b">{title || 'Are you sure?'}</div>
      <div className="mt3">{children}</div>
      <div className="mt3 flex justify-between">
        <button className="large border" onClick={() => viewState[1](false)}>
          No
        </button>
        <button className="large" onClick={onConfirm}>
          Yes
        </button>
      </div>
    </Modal>
  )
}

export default Confirm
