import React from 'react'

function FuzzBox(props) {
  let color = 'rgba(255,255,255,0.8)'
  if (props.tint === 'dark') {
    color = 'rgba(0,0,0,0.5)'
  } else if (props.tint !== 'light') {
    color = props.tint
  }

  return (
    <div
      style={{
        backgroundColor: color,
        backdropFilter: 'blur(8px)',
        ...props.style
      }}
      {...props}
    />
  )
}
export default FuzzBox
