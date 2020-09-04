import React from 'react'
export function Header(props) {
  return (
    <div className="fo-alt-yellow pv1 pv2-ns ph2 ph3-l tl theme-frame-greater w-100 f6 b mr2 ttu">
      {props.children}
    </div>
  )
}
export default Header
