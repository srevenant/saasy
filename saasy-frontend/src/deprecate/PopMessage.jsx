import React from 'react'
import style from './PopMessage.module.scss'

function PopMessage({ msg, set }) {
  // auto-closer here
  return (
    <div
      className={`theme-frame scroller flex-center ${style.pop}`}
      onKeyDown={(e) => {
        // console.log('E', e)
        if (e.key === 'Escape') {
          set(null)
        }
      }}
    >
      <div className={style.close} onClick={() => set(null)}>
        <i className="fas fa-times b tr fo-text-white" />
      </div>
      <div>{msg}</div>
    </div>
  )
}

export default PopMessage
