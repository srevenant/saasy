import moment from 'moment'

export function fromNowShort(time, arg1) {
  if (!time) {
    return ''
  }
  moment.updateLocale('en', {
    relativeTime: {
      future: 'in %s',
      past: '%s ago',
      s: function (number, withoutSuffix) {
        return withoutSuffix ? 'now' : 'a few seconds'
      },
      m: '1m',
      mm: '%dm',
      h: '1h',
      hh: '%dh',
      d: '1d',
      dd: '%dd',
      M: '1mo',
      MM: '%dmo',
      y: '1y',
      yy: '%dy'
    }
  })
  return moment(time).fromNow(true) // .replace(/^a /, '1 ')
}

export function fromNow(time, arg1) {
  if (!time) {
    return ''
  }
  return moment(time).fromNow(arg1).replace(/^a /, '1 ')
}

const msPerSecond = 1000
const msPerMinute = msPerSecond * 60
const msPerHour = msPerMinute * 60
const msPerDay = msPerHour * 24
const msPerMonth = msPerDay * 30
const msPerYear = msPerDay * 365

function _timePart(ms) {
  if (ms < msPerMinute) {
    return [Math.floor(ms / msPerSecond), 'sec', msPerSecond]
  } else if (ms < msPerHour) {
    return [Math.floor(ms / msPerMinute), 'min', msPerMinute]
  } else if (ms < msPerDay) {
    return [Math.floor(ms / msPerHour), 'hr', msPerHour]
  } else if (ms < msPerMonth) {
    return [Math.floor(ms / msPerDay), 'day', msPerDay]
  } else if (ms < msPerYear) {
    return [Math.floor(ms / msPerMonth), 'mo', msPerMonth]
  }
  return [Math.floor(ms / msPerYear), 'year', msPerYear]
}

function timePart(ms) {
  let [num, label, chunk] = _timePart(ms)
  if (num > 1) {
    return [num, label + 's', chunk]
  }
  return [num, label, chunk]
}

// all the parts
export function timeDifferenceParts(current, previous) {
  let elapsed = current - previous
  let result = []
  while (elapsed > msPerSecond) {
    const [num, label, chunk] = timePart(elapsed)
    if (num <= 0) {
      return result
    }
    result.push(`${num} ${label}`)
    // @ts-ignore
    elapsed -= num * chunk
  }
  return result
}

// just the biggest component
export function timeDifference(current, previous) {
  const elapsed = current - previous

  if (elapsed < msPerMinute / 3) {
    return 'just now'
  }
  if (elapsed < msPerMinute) {
    return 'less than 1 min ago'
  }

  const [num, label] = timePart(elapsed)

  return `${num} ${label} ago`
}

export function secondsForHuman(seconds) {
  if (seconds > 86400) {
    return `${Math.round(seconds / 86400)}d`
  } else if (seconds > 3600) {
    return `${Math.round(seconds / 3600)}h`
  } else {
    return `${Math.round(seconds / 60)}m`
  }
}

export function timeDifferenceForDate(date) {
  const now = new Date().getTime()
  const updated = new Date(date).getTime()
  return timeDifference(now, updated)
}

export function formatDateTime(date) {
  return date.replace(/T/, ' ')
}

export function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms))
}

// receive whatever they type, make sure it's what we want, returning
// both the server-server format, and the user-format
export function parseInputTime(str) {}
