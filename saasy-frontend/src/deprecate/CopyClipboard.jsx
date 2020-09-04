import React, { useState, useEffect } from 'react'
import copy from 'clipboard-copy'

export default function CopyClipboard(props) {
  const [show, setShow] = useState(undefined)
  const { value, icon, className, bclassName } = props

  useEffect(() => {
    let isMounted = true
    setTimeout(() => {
      if (isMounted) {
        setShow(undefined)
      }
    }, 3000)

    // return the function to "unmount"
    return () => (isMounted = false)
  }, [show])

  return (
    <>
      {show ? (
        <div
          className="theme-frame ba b--t-primary br2 pa2"
          style={{ position: 'fixed', bottom: '1rem', right: '1rem' }}
        >
          {show}
        </div>
      ) : null}
      <div className={className ? className : ''}>
        <button
          className={`${bclassName ? bclassName : ''} flex-center`}
          style={{ width: 'inherit', margin: 0, padding: 0 }}
          onClick={() => {
            copy(value)
            setShow(<>Link copied to clipboard</>)
          }}
        >
          <i className={icon ? icon : 'fas fa-copy'} />
          {props.children}
        </button>
      </div>
    </>
  )
}
