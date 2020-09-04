import React, { useEffect, useRef } from 'react'
import Modal from 'tools/Modal'

////////////////////////////////////////////////////////////////////////////////
// throttle the internal messaging so it doesn't overload things
let LOG_ARRAY = []
let LOG_LAST_REFRESH = 0
export function addLog(line, setShow, force) {
  LOG_ARRAY.push(<>{line}</>)
  if (force || Date.now() - LOG_LAST_REFRESH > 500) {
    LOG_LAST_REFRESH = Date.now()
    setShow(LOG_ARRAY.length)
  }
}

////////////////////////////////////////////////////////////////////////////////
export function MessageLog({ show, setShow }) {
  const messagesEndRef = useRef(null)
  useEffect(() => {
    messagesEndRef.current &&
      messagesEndRef.current.scrollIntoView({ behavior: 'smooth' })
  }, [])

  if (!show) {
    return null
  }
  return (
    <Modal
      viewState={[show, setShow]}
      width="fw-50"
      header="Importing - please wait"
    >
      <div className="mt2">
        {LOG_ARRAY.map((line, x) => (
          <div key={x}>{line}</div>
        ))}
        <div ref={messagesEndRef} />
      </div>
    </Modal>
  )
}

// this isn't right -BJG
// export function MessageLogAuto({children, ...props}) {
//   const [show, setShow] = useState(0)
//   useEffect(() => {
//     let isMounted = true
//     setTimeout(() => {
//       if (isMounted) {
//         setShow(0)
//       }
//     }, 3000)
//
//     // return the function to "unmount"
//     return () => (isMounted = false)
//   })
//   return <MessageLog show={show} setShow={setShow} {...props} />
// }
