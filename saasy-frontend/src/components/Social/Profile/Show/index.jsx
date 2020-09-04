import React, { useContext } from 'react'
import ProfileContext from '../resolver'
import MemberProjects from './Projects'
import { Avatar } from '../Label'
import { fromNow, fromNowShort } from 'utils/time'
import { strcmp, capitalize } from 'utils/string'

////////////////////////////////////////////////////////////////////////////////
function Show() {
  const [{ person }] = useContext(ProfileContext)

  return (
    <div className="pa4">
      <Avatar person={person} large={true} />
      <div className="f3 b mt4 mb2">
        {person.name}
        <span className="f4 fw3 ml3">~{person.handle}</span>
      </div>
      <div className="f4 mb2">{getData(person, 'profile', 'desc')}</div>
      <div className="f5 mb2 flex">
        {getLocation(person)}
        <b className="mh2">&#xb7;</b>
        <div className={`flex fw2`}>
          Last visited: <LastSeen person={person} long={true} className="mh2" />
        </div>
      </div>
      <ShowIfIs type="contributor" person={person}>
        <ListTags label="Preferred Role" type="role" person={person} />
        <ListTags label="Strength" type="skill" person={person} />
      </ShowIfIs>

      <ShowIfIs type="investor" person={person}>
        <ul className="less">
          {person.toggles.accredited ? (
            <li>Is an accredited investor (UNVERIFIED)</li>
          ) : null}
          {person.toggles.proxy ? (
            <li>
              Works for an accredited investor or investment firm (UNVERIFIED)
            </li>
          ) : null}
        </ul>
      </ShowIfIs>

      <ShowIfIs type="provider" person={person}>
        <ListTags label="Service" type="service" person={person} />
      </ShowIfIs>

      <MemberProjects person={person} />
    </div>
  )
}

export default Show

////////////////////////////////////////////////////////////////////////////////
function getLocation(person) {
  let location = []
  addIf(location, getData(person, 'address', 'city'))
  addIf(location, getData(person, 'address', 'state'))
  addIf(location, getData(person, 'address', 'country'))
  return location.join(', ')
}

function getData(person, type, subkey) {
  let value = {}
  if (person.dataTypes[type]) {
    value = person.dataTypes[type].value
  }
  if (subkey) {
    return value[subkey] || ''
  }
  return value
}

function addIf(array, data) {
  if (data) {
    array.push(data)
  }
}

function trim(s) {
  if (s && s.length > 45) {
    return s.slice(0, 40) + '...'
  }
  return s
}

////////////////////////////////////////////////////////////////////////////////
export function LastSeen({ person, long = false, className = '' }) {
  return (
    <div className={className}>
      {long ? fromNow(person.lastSeen) : fromNowShort(person.lastSeen)}
    </div>
  )
}

////////////////////////////////////////////////////////////////////////////////
export function Desc({ person, prefix = <b>&#xb7;&nbsp;</b> }) {
  const hilights = person.dataTypes.profile
  return (
    <span>
      {hilights ? (
        <>
          {prefix}
          {trim(hilights.value.desc)}
        </>
      ) : null}
    </span>
  )
}

////////////////////////////////////////////////////////////////////////////////
function ListTags({ label, type, person }) {
  const list = person.tagsD[type] || []
  return (
    <>
      <div>
        <b>
          {label}
          {list.length > 1 ? 's' : ''}:
        </b>
      </div>
      <ul className="less">
        {list
          .sort((a, b) => strcmp(a.label, b.label))
          .map((r, x) => (
            <li key={`taglist-${type}-${x}`}>{r.label}</li>
          ))}
        {list.length === 0 ? (
          <li className="i fw2 gray">No {type}s chosen</li>
        ) : null}
      </ul>
    </>
  )
}

////////////////////////////////////////////////////////////////////////////////
function ShowIfIs({ type, person, children }) {
  if (!person.toggles[type]) {
    return null
  }
  return (
    <>
      <label className="heading mt4 mb3">{capitalize(type)}</label>
      {children}
    </>
  )
}
