import React from 'react'
/*
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faPaperPlane as Play } from '@fortawesome/free-solid-svg-icons'
import { faBuilding as Work } from '@fortawesome/free-solid-svg-icons'
//import { faHome as Home } from '@fortawesome/free-solid-svg-icons'
import { faCircle as Unknown } from '@fortawesome/free-solid-svg-icons'
import { faExclamation as Error } from '@fortawesome/free-solid-svg-icons'
import { faTimes as Close } from '@fortawesome/free-solid-svg-icons'
import { faPaperclip as Attach } from '@fortawesome/free-solid-svg-icons'
import { faPencilAlt as Edit } from '@fortawesome/free-solid-svg-icons'
import { faLink as Link } from '@fortawesome/free-solid-svg-icons'
*/
import { istyle } from '../utils/istyle'

// a lot of this should move to constants
export const icons = {
  name: {},
  behavior: {
    close: { c: 'fas fa-times', s: {}, x: {} },
    edit: { c: 'fas fa-pencil-alt', s: {}, x: {} },
    attach: { c: 'fas fa-paperclip', s: {}, x: {} },
    link: { c: 'fas fa-link', s: {}, x: {} }
  },
  acat: {
    work: { c: 'fas fa-money-bill c<blue>', s: {}, x: {} },
    personal: { c: 'fas fa-paper-plane c<green>', s: {}, x: {} },
    _unknown: { c: 'fas fa-circle v<v-mid> c<red>', s: {}, x: {} }
  },
  atype: {
    activity: {
      c: 'fas fa-user',
      s: {},
      x: {},
      header: true,
      explain: 'Your Journal'
    },
    actsum: {
      c: 'fas fa-user-plus',
      s: {},
      x: {},
      header: true,
      explain: 'Activity Summary'
    },
    location: {
      c: 'fas fa-map-marker-alt',
      s: {},
      x: {},
      header: true,
      explain: 'Location'
    },
    calendar: {
      c: 'fas fa-calendar-week',
      s: {},
      x: {},
      header: true,
      explain: 'Calendar'
    },
    phonecall: {
      c: 'fas fa-phone',
      s: {},
      x: {},
      header: true,
      explain: 'Call Logs'
    },
    goal: {
      c: 'fas fa-bullseye',
      s: {},
      x: {},
      header: true,
      explain: 'Goals'
    },
    accomplishment: {
      c: 'fas fa-check-circle',
      s: {},
      x: {},
      header: true,
      explain: 'Accomplishments'
    },
    missed: {
      c: 'fas fa-times-circle',
      s: {},
      x: {},
      header: true,
      explain: 'Missed Goals'
    },
    error: {
      c: 'fas fa-exclamation f<f7> c<red>',
      s: {},
      x: {},
      header: false,
      explain: 'Errors'
    },
    summary: {
      c: 'fas fa-brain',
      s: {},
      x: {},
      header: false,
      explain: 'Summary'
    },
    attribs: {
      c: 'fas fa-hashtag',
      s: {},
      x: {},
      header: true,
      explain: 'Attributes'
    }
  }
}

function get_idata(props, type, fallback) {
  const key = props[type]
  if (key) {
    let value = icons[type][key]
    if (!value) {
      if (fallback) {
        icons[type][key] = { c: 'fas fa-' + key, s: {}, x: {} }
        value = icons[type][key]
      } else {
        throw new Error(`Missing icon definition for ${type}.${key}, sorry!`)
      }
    }
    return value
  }
  return undefined
}

export function Icon(props) {
  let types = [
    ['name', true],
    ['acat', true],
    ['atype', false],
    ['behavior', false]
  ]
  let idef = undefined
  do {
    idef = get_idata(props, ...types.shift())
  } while (idef === undefined && types.length)

  if (idef === undefined) {
    throw new Error(
      `Missing icon definition in props, try one of: name, acat, atype, behavior`
    )
  }

  // been there, use cache
  let classes = ''
  if (idef.x[props.classes]) {
    classes = idef.x[props.classes]
  } else {
    // first reconcile defaults
    classes = istyle('p<pr1 pr2-ns pl1 pl2-ns> f<f7>', idef.c)
    classes = istyle(classes, props.classes)
    idef.x[props.classes] = classes
  }

  let style = Object.assign({}, idef.s)
  if (props.style && Object.keys(props.style).length > 0) {
    style = Object.assign(style, props.style)
  }

  let more = {}
  if (props.onClick) {
    more = { ...more, onClick: props.onClick }
  }

  let toggle = props.toggleclass
  if (!toggle) {
    toggle = (c) => {
      return c
    }
  }
  return (
    <div className={toggle(classes)} style={style} {...more}>
      {props.children}
    </div>
  )
}

export default icons
