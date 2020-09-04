import React from 'react'
import style from './index.module.scss'

////////////////////////////////////////////////////////////////////////////////
export function StatusBox({ message }) {
  return (
    <div className="tc fw2">
      {message ? (
        <div className={`${style.authstatus} dark-red visible pa2 mt2`}>
          {message}
        </div>
      ) : (
        <div className={`${style.authstatus} dark-red hidden`}></div>
      )}
    </div>
  )
}

export default StatusBox
