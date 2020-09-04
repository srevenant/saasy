import React, { useState } from 'react'
import Modal from 'tools/Modal'

function Popup({ children, title = '', className = '' }) {
  const [show, setShow] = useState(false)
  return (
    <>
      <i
        className={`fas pa1 br3 fa-question-circle light-silver ml2 pointer hover-lighten ${className}`}
        onClick={() => setShow(true)}
      />
      {show ? (
        <Modal
          viewState={[show, setShow]}
          width="fw-50"
          className="theme-frame theme-bg-flat"
        >
          {title ? <div className="pa3 f4">{title}</div> : null}
          <div className="ph5 pt3 pb5 lh-copy">{children}</div>
        </Modal>
      ) : null}
    </>
  )
}

export default Popup
