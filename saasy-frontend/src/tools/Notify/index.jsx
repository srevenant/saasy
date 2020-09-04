import React, { useContext, useEffect } from 'react'
import { NotifyStore, CLEAR_MESSAGES, REMOVE_MESSAGE } from './resolver'
import Store from '../../store'
import style from './index.module.scss'

export function Notify() {
  const [msgs, dispatch] = useContext(NotifyStore)
  const [, globalDispatch] = useContext(Store)

  const autoExpireMsgs = msgs.filter((msg) => msg.expire).length
  useEffect(() => {
    if (autoExpireMsgs > 0) {
      let isMounted = true
      setTimeout(() => {
        if (isMounted) {
          dispatch({ type: CLEAR_MESSAGES })
        }
      }, 3000)

      return () => (isMounted = false)
    }
  }, [autoExpireMsgs, dispatch])

  const hide = (id) => dispatch({ type: REMOVE_MESSAGE, value: id })
  if (msgs.length === 0) return null

  return (
    <div className={style.msgWrap}>
      {msgs.map((msg) => (
        <div
          key={msg.id}
          className={`${style.msg} ${style[msg.type]}`}
          onClick={() => {
            hide(msg.id)
            if (msg.onClick) {
              msg.onClick(globalDispatch)
            }
          }}
        >
          <div
            className={style.close}
            onClick={(e) => {
              e.stopPropagation()
              hide(msg.id)
            }}
          >
            <i className="fas fa-times" />
          </div>
          {msg.content}
        </div>
      ))}
    </div>
  )
}

export default Notify
