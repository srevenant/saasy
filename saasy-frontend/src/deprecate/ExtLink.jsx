import React from 'react'

function ExtLink({ to, children, className = '' }) {
  return (
    <a href={to} className={className} rel="noopener noreferrer" target="_blank">
      {children}
    </a>
  )
}

export default ExtLink
