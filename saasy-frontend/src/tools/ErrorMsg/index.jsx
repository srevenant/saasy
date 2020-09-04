import React from 'react'

function ErrorMsg({ title = '', children = 'Sorry!  Something went wrong!' }) {
  return (
    <div className="flex-center h-100">
      <div className="mb6">
        {title ? <div className="f3 b">{title}</div> : null}
        <div className="f4">{children}</div>
      </div>
    </div>
  )
}

export default ErrorMsg
