import React, { useContext } from 'react'
import { NavLink, MenuLink } from 'tools/Links'
import Store from 'store'
import style from './index.module.scss'
import { MenuList, MenuButton } from 'react-menu-list'

export function ProfileMenu({ className = '' }) {
  const [state] = useContext(Store)

  if (state.user.authStatus === 'unknown') {
    return (
      <NavLink
        to="/signon"
        className={`navlink ${style.navlink}`}
        logOrigin="SignOn"
        icon={<>sign in</>}
      />
    )
  } else {
    return (
      <MenuButton
        positionOptions={{ position: 'bottom', vAlign: 'top', hAlign: 'left' }}
        menu={
          <div className={`pv1 pv2-m pv2-l white mt1 navbar-bg menu`}>
            <MenuList>
              <MenuLink
                to="/prefs/profile"
                label="Preferences"
                logOrigin="Prefs"
              />
              <MenuLink
                to="/r/_/private"
                label="My Reactors"
                logOrigin="List Mine"
              />
              <MenuLink to="/signout" label="signout" logOrigin="Signout" />
              {state.user.can('auth_admin') ? (
                <>
                  <MenuLink
                    to="/adm/users"
                    label="user admin"
                    className="bt b--gray pt2"
                    logOrigin="SupportUser"
                  />
                </>
              ) : (
                <></>
              )}
            </MenuList>
          </div>
        }
        className={`navlink ${style.navlink} ${className} clear`}
      >
        <i className="fas fa-bars pa2" style={{ fontSize: '1rem' }} />
      </MenuButton>
    )
  }
}

// <MenuLink to="/help" label="help" logOrigin="Help" />

export default ProfileMenu
