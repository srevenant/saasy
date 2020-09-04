import React from 'react'
import { normalizePublicUser } from 'utils/user'
import style from './index.module.scss'
import istyle from '../Picture/index.module.scss'
import config from 'constants/config'
import { Link } from 'tools/Links'
import { ControlIcon } from 'tools/Controls'
import { fromNowShort } from 'utils/time'

function PersonLabel({
  person,
  onClick = undefined,
  icon = 'fas fa-plus',
  showHandle = true,
  showLast = false,
  showDesc = true,
  showPic = true,
  float = true,
  className = ''
}) {
  normalizePublicUser(person)
  return (
    <div
      className={`${style.person} ${
        onClick ? 'pointer hover-hilight' : ''
      } ${className}`}
      onClick={onClick}
    >
      {showPic && <Avatar person={person} />}
      {showLast && <LastSeen person={person} />}
      <Name person={person} />
      {showHandle && <Handle person={person} />}
      {showDesc && <Desc person={person} />}
      {onClick ? (
        <div
          className={`${style.icon} ${style.floatEdit} theme-fg-hilight flex items-center nowrap`}
        >
          <ControlIcon onClick={undefined} icon="fas fa-plus" /> <b>Add</b>
        </div>
      ) : null}
    </div>
  )
}

export function LastSeen({ person }) {
  return <div className={style.time}>{fromNowShort(person.lastSeen)}</div>
}

export function Avatar({ person, className = '', large = false, round = true }) {
  normalizePublicUser(person)
  let avatar = person.avatar.url
  if (!avatar) {
    if (person.avatar.path) {
      avatar = `${config.imgurl}${person.avatar.path}`
    } else {
      const loc = parseInt(person.id.slice(0, 8)) % 10
      avatar = `${config.imgurl}default/lego-${loc || 0}.jpg`
    }
  }
  return (
    <div
      className={`${style.image} ${istyle.image} ${className} ${
        large ? istyle.large : ''
      } ${avatar ? istyle.round : ''}`}
    >
      <img src={avatar} alt="" />
    </div>
  )
}
// <i className="fas fa-user gray f3" />

export function Handle({ person }) {
  return <span className={style.handle}>u/{person.handle}</span>
}

export function Name({ person }) {
  return (
    <span className={`${style.name} nowrap`}>
      {person.handle ? (
        <Link to={`/u/${person.handle}`} className="plain">
          {person.name}
        </Link>
      ) : (
        person.handle
      )}
    </span>
  )
}

export function Desc({ person, prefix = <b>&#xb7;&nbsp;</b> }) {
  const hilights = person.dataTypes.profile
  return (
    <span className={style.desc}>
      {hilights ? (
        <>
          {prefix}
          {trim(hilights.value.desc)}
        </>
      ) : null}
    </span>
  )
}

function trim(s) {
  if (s && s.length > 45) {
    return s.slice(0, 40) + '...'
  }
  return s
}

export default PersonLabel
export { style }
