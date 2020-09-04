import React, { useState } from 'react'
import { Link, useHistory } from 'react-router-dom'
import { navigate } from '../utils/history'

export const Clickable = (props) => {
  let { onClick, type, icon, to, as, children, ...other } = props
  const history = useHistory()

  if (!type) {
    type = 'button'
  }
  let padchild = ''
  if (children && icon) {
    padchild = 'mr2'
  }
  if (!onClick) {
    if (to) {
      onClick = () => {
        navigate(history, to)
      }
    }
  }
  if (as === 'link') {
    return (
      <Link
        className={`${type} pa2 ma0 ml2 nobr`}
        to={to}
        onClick={onClick}
        {...other}
      >
        {icon ? <i className={`fas fa-${icon} ${padchild}`} /> : <></>}
        {children}
      </Link>
    )
  } else {
    return (
      <button className={`${type} pa2 ma0 ml2 nobr`} onClick={onClick} {...other}>
        {icon ? <i className={`fas fa-${icon} ${padchild}`} /> : <></>}
        {children}
      </button>
    )
  }
}

export const Button = Clickable

export const Input = (props) => {
  const defaultBgColor = props.bgColor || 'inherit'
  const [stateBgColor, updateBgColor] = useState(defaultBgColor)
  const [style, { fwdRef, className, bgColor, ...other }] = sliceStyleMerge(
    props,
    {
      backgroundColor: stateBgColor
    }
  )
  let classes = new Set()
  if (className) {
    const addClasses = className.split(' ')
    for (let x in addClasses) {
      const cls = addClasses[x]
      classes.add(cls)
    }
  } else {
    classes = new Set(['w-100', 'br2', 'ma0', 'ba', 'b--transparent'])
  }
  return (
    <input
      type="text"
      ref={fwdRef}
      className={Array.from(classes).join(' ')}
      style={style}
      {...other}
      onFocus={() => {
        updateBgColor('white')
      }}
      onBlur={() => {
        updateBgColor(defaultBgColor)
      }}
    />
  )
}

export const Textarea = (props) => {
  const defaultBgColor = props.bgColor || 'inherit'
  const [stateBgColor, updateBgColor] = useState(defaultBgColor)
  const [
    newStyle,
    { fwdRef, style, className, children, bgColor, ...other }
  ] = sliceStyleMerge(props, {
    backgroundColor: stateBgColor
  })
  let classes = new Set()
  if (className) {
    const addClasses = className.split(' ')
    for (let x in addClasses) {
      const cls = addClasses[x]
      classes.add(cls)
    }
  } else {
    classes = new Set(['w-100', 'br2', 'ma0', 'ba', 'b--transparent'])
  }
  return (
    <textarea
      rows="1"
      ref={fwdRef}
      style={newStyle}
      className={Array.from(classes).join(' ')}
      {...other}
      onFocus={() => {
        updateBgColor('white')
      }}
      onBlur={() => {
        updateBgColor(defaultBgColor)
      }}
    >
      {children}
    </textarea>
  )
}

/*
grr, I want to merge style, but props.style comes in immutable,
there has to be an easier way to do this
*/
function sliceStyleMerge(props, newStyle) {
  const { style, ...other } = props
  const merged = Object.assign({}, style || {}, newStyle)
  return [merged, other]
}

export const Cell = (props) => {
  let { children, ...other } = props
  let style = {}
  if (props.width) {
    ;[style, other] = sliceStyleMerge(props, { width: props.width })
  }
  return (
    <div {...other} style={style}>
      {props.children}
    </div>
  )
}

export function Checkbox({ value, setValue, defaultValue, className }) {
  return (
    <input
      className={className}
      type="checkbox"
      checked={value}
      defaultValue={defaultValue}
      onChange={(e) => {
        setValue(e.target.checked)
      }}
    />
  )
}
