import React, { useContext } from 'react'
import {
  useHistory,
  NavLink as InnerNavLink,
  Link as InnerLink
} from 'react-router-dom'
import style from 'components/Root/NavBar/index.module.scss'
import { MenuItem } from 'react-menu-list'
import Store, { USER_CLICKED } from 'store'
import log from 'utils/log'

function linkTo({ props, state, dispatch, history }) {
  let { logOrigin, onClick: onClickInner, to, back, ...args } = props

  let logClick = undefined

  if (logOrigin) {
    logClick = (ev) => {
      log.event({
        category: 'NavLink',
        action: 'click',
        label: logOrigin
      })
    }
  }
  if (back) {
    let dest = state.history[state.history.length - 1] || '/'
    if (dest === history.location.pathname) {
      dest = state.history[state.history.length - 2] || '/'
    }
    to = dest
  }
  let onClick = (ev) => {
    console.log('CLICK', to)
    logClick && logClick()
    if (to) {
      dispatch({ type: USER_CLICKED, value: to })
    }
    onClickInner && onClickInner(ev, to)
  }

  return { ...args, to, onClick }
}

// type can be 'div', 'disable', 'Link', or 'span' as well
export function Link({ type = 'Link', ...props }) {
  const history = useHistory()
  const [state, dispatch] = useContext(Store)

  const args = linkTo({ props, state, dispatch, history })
  let { onClick, to, ...rest } = args
  const onClickWrap = (ev) => {
    onClick(ev)
    history.push(to)
  }
  switch (type) {
    case 'disable':
      return <div {...rest} />
    case 'div':
      return <div {...rest} onClick={onClickWrap} />
    case 'span':
      return <span {...rest} onClick={onClickWrap} />
    default:
      return <InnerLink {...args} />
  }
}

export function NavLink(props) {
  const history = useHistory()
  const [state, dispatch] = useContext(Store)
  let {
    disable,
    icon,
    bareStyle,
    className,
    label,
    children,
    smHideLabel,
    ...rest
  } = props

  const args = linkTo({ props: rest, state, dispatch, history })

  let mylabel = label || children

  // hide it on small
  if (smHideLabel) {
    mylabel = <div className="dn db-ns">{mylabel}</div>
  }
  if (!bareStyle) {
    className = `navlink ${style.navlink} pa1 pa2-m pa2-l ${className}`
  }

  return (
    <InnerNavLink activeClassName="active" className={className} {...args}>
      <div className="flex items-center nowrap">
        {icon}
        {mylabel}
      </div>
    </InnerNavLink>
  )
}

// react-menu-list
export function MenuLink(props) {
  const { className, ...other } = props
  return (
    <MenuItem className={className}>
      <NavLink className="w-100 tl" {...other} />
    </MenuItem>
  )
}

export function ExtLink({ to, children, className = '' }) {
  return (
    <a href={to} className={className} rel="noopener noreferrer" target="_blank">
      {children}
    </a>
  )
}

export default Link
