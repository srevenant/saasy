import React from 'react'

export function HeadLabel(props) {
  let { children, size } = props
  if (!size) {
    size = 'f6'
  }
  return <label className={`${size} b db mb2 mt3 mid-gray`}>{children}</label>
}
