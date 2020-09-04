import React from 'react'
import estyle from './index.module.scss'
import { Link } from 'tools/Links'

export function Controls({ children, className = '', style = {} }) {
  return (
    <div className={`${estyle.controls} ${className}`} style={style}>
      {children}
    </div>
  )
}

export function ControlIcon({
  onClick = undefined,
  back = false,
  to = undefined,
  children = undefined,
  icon = undefined,
  variant = 'header',
  className = '',
  style = {}
}) {
  if (icon) {
    children = <i className={icon} />
  }
  return (
    <Link
      type="div"
      className={`${estyle.control} ${estyle[variant]} ${
        variant === 'inline' ? 'theme-bg-hilight' : ''
      } ${className}`}
      style={style}
      back={back}
      to={to}
      onClick={onClick}
    >
      <div className={estyle.content}>{children}</div>
    </Link>
  )
}
