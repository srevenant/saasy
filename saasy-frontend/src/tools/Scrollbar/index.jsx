import React from 'react'

export function Scrollbar(props) {
  const { className = '', children, ...rest } = props
  return (
    <div className={`scroller pb3 ${className}`} {...rest}>
      {children}
    </div>
  )
}

export default Scrollbar
