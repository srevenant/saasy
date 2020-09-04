import React from 'react'
import { NavLink } from 'tools/Links'
import ProfileMenu from './ProfileMenu'
import style from './index.module.scss'

export function NavBar() {
  return (
    <div
      className={`navbar ${style.navbar} ma0 pa1 flex items-center justify-between`}
    >
      <NavLink
        to="/"
        exact={true}
        label=""
        icon={
          <img
            src=""
            alt="LOGO"
            style={{ height: '1.5rem' }}
            className="logo mr2"
          />
        }
      />
      <NavLink
        to="/connect"
        label={
          <>
            <i className="fas fa-plug mr2" />
            connect
          </>
        }
        className="ml-auto mr3"
      />
      <NavLink
        to="/r/"
        label={
          <>
            <i className="fas fa-users mr2" />
            reactors
          </>
        }
        className="mr3"
      />
      <NavLink
        to="/g/"
        label={
          <>
            <i className="fas fa-route mr2" />
            goals
          </>
        }
        className="mr3"
      />
      <ProfileMenu className="" />
    </div>
  )
}
// <NavLink to="/feed" label="latest" className="ml-auto" />
// <NavLink to="/journey" label="projects" className="" />
// <NavLink to="/connect" label="connect" className="ml-auto" />
// <NavLink to="/events" label="events" className="ml-auto" />

export default NavBar
