import React from 'react'
import { MenuList, MenuButton, MenuItem } from 'react-menu-list'
import style from './index.module.scss'

function Chooser({ prefs, setPref, type, options, multi = undefined }) {
  let current
  let label
  if (multi) {
    current = prefs[type] || options.filter((o) => o.default).map((o) => o.value)
    // current = options.filter((o) => cur.includes(o.value))
    label = `${multi} ${current.length ? ` (${current.length}) ` : ''}`
  } else {
    current = options.find((o) => {
      return o.value === prefs[type]
    })
    if (!current) {
      current = options.find((o) => o.default)
    }
    label = current ? current.title || current.label : 'no label'
  }
  const props = { current, setPref, type, prefs }
  return (
    <Menu
      label={
        <div className="navlink">
          {label} <i className="fas fa-chevron-down" />
        </div>
      }
      className="mr3"
      multi={multi}
    >
      {options.map((o) => (
        <Option key={o.value} opt={o} {...props} multi={multi} />
      ))}
    </Menu>
  )
}

function Menu({ children, label, className = '', multi = undefined }) {
  return (
    <MenuButton
      className={className}
      positionOptions={{ position: 'bottom', vAlign: 'top', hAlign: 'left' }}
      menuZIndex={41000}
      menu={
        <div className={`menu theme-bg-flat navMenu ${style.menu}`}>
          <MenuList>{children}</MenuList>
        </div>
      }
    >
      {label}
    </MenuButton>
  )
}

function Option({ current, opt, setPref, prefs, type, multi }) {
  let active
  if (multi) active = current.includes((opt || {}).value)
  else active = (opt || {}).value === current

  return (
    <MenuItem
      className={`navlink ${style.item} ${active ? 'active' : ''}`}
      onItemChosen={() => false}
    >
      <div
        onClick={() => {
          if (multi) {
            if (active)
              setPref(
                type,
                current.filter((o) => o !== opt.value)
              )
            else setPref(type, current.concat(opt.value))
          } else {
            setPref(type, opt.value)
          }
        }}
      >
        {multi ? (
          <i
            className={`fas fa-check mr2 ${active ? '' : 'theme-fg-minimize'}`}
          />
        ) : (
          <></>
        )}
        {opt.label}
      </div>
    </MenuItem>
  )
}

export default Chooser
