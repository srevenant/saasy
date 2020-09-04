import moment from 'moment'

/*

{interval}          - {num} hr|min|sec
                    - default assumption; subtract interval from now for range
{interval} @ {time} - where
{time} + {interval}
{time} - {time}

*/
/*
const // DEBUG = () => {}
const // DEBUG = (...args) => { console.log("----->", ...args) }
*/

const DURATION = /^\s*([0-9.]+)\s*([a-z]+)?$/i
const DURATIONS = [
  {
    rx: /^(m|min(s)?|minute(s)?)$/i,
    fn: (num, matchf) => {
      return num * 60
    }
  },
  {
    rx: /^(h|hr(s)?|hour(s)?)$/i,
    fn: (num, match) => {
      return num * 60 * 60
    }
  },
  {
    rx: /^(d|day(s)?)$/i,
    fn: (num, match) => {
      return num * 60 * 60 * 24
    }
  },
  {
    rx: /^(s|sec(s)?|second(s)?)$/i,
    fn: (num, match) => {
      return (num / 60) * 60
    }
  },
  {
    rx: /now/i,
    fn: (num, match) => {
      return 0
    }
  },
  {
    rx: /^$/,
    fn: (num, match) => {
      return num * 60
    }
  }
]

const HRMN = /^\s*((\d+):(\d+))\s*((p|a)m?)?\s*$/i
const RANGES = [
  {
    rx: HRMN,
    fn: (origin, match, _input) => {
      // DEBUG(`FN1 (${origin}, ${match}, _)`)
      const stime = timeAt(match, origin)
      return [stime, stime]
    }
  },

  // 30m@12:30
  {
    rx: /^\s*([0-9.]+)\s*([a-z]+)\s*@\s*((\d+):(\d+))\s*((p|a)m?)?\s*$/i,
    fn: (origin, match, _input) => {
      // match [0:"30m@12:30", 1:"30", 2:"m", 3:"12:30", 4:"12", 5:"30", ...]
      // DEBUG(`FN2 (${origin}, ${match}, _)`)
      // expect [string, "hr:mn", "hr", "mn", "am", "a", ...]
      const stime = timeAt(match.slice(2, 6), origin)
      // DEBUG(`stime=>${stime}`)
      const secs = durationAsSecondsMatch(match.slice(0, 3))
      // DEBUG(`secs=>${stime}`)
      if (secs) {
        return [stime, timeAdd(stime, { s: secs })]
      }
    }
  },

  // 12:30-1:30pm
  {
    rx: /^\s*((\d+):(\d+))\s*((p|a)m?)?\s*-\s*(.+)\s*$/i,
    fn: (origin, match, _input) => {
      // DEBUG(`FN3 (${origin}, ${match}, _)`)
      const stime = timeAt(match.slice(0, 5), origin)
      if (stime) {
        return timeHrMn(match[6], stime)
      }
    }
  },

  // 12:30+30m      -- similar to 30m@12:30
  {
    rx: /^\s*((\d+):(\d+))\s*((p|a)m?)?\s*\+\s*(.+)\s*$/i,
    fn: (origin, match, _input) => {
      // DEBUG(`FN4 (${origin}, ${match}, _)`)
      const stime = timeAt(match.slice(0, 6), origin)
      const secs = durationAsSecondsString(match[6])
      if (secs) {
        return [stime, timeAdd(stime, { s: secs })]
      }
    }
  },

  // 2019-6-26 10:30p +15m // minimum
  // 2019-6-26T10:30-0600 +15m // ISO
  // 2019-6-26 T 10:30 -0600 +15m // + some human variants
  // 2019-6-26 T 10:30 pm -0600 +15m
  // 2019-6-26 10:30p +15m

  //  { rx: /^\s*(\d{4})-(\d+)-(\d+)\s*(\d+):(\d+)\s*((p|a)m?)?\s*(-\d+)\s*\+\s*(\d+)\s*([a-z]+)?\s*$/i,
  {
    rx: /^\s*(\d{4})-(\d+)-(\d+)\s*(T|\s)?\s*(\d+):(\d+)\s*((p|a)m?)?\s*(-\d+)?\s*\+\s*([0-9.]+)\s*([a-z]+)?\s*$/i,
    fn: (origin, match, _input) => {
      // DEBUG(`FN5 (${origin}, ${match}, _)`)
      // match [0:"2019-6-26 10:30p +15m", 1:"2019", 2:"6", 3:"26", 4:null, 5:"10", 6:"30", 7:"p", 8:"p", 9:null, 10:"15", 11:"m", ..
      // timeAt([string, "hr:mn", "hr", "mn", "am", "a", ...])
      const date = moment(`${match[1]}-${match[2]}-${match[3]}T00:00:00`).unix()
      if (isNaN(date)) {
        return undefined
      }
      const stime = timeAt(match.slice(3, 9), date)
      const secs = durationAsSecondsMatch(match.slice(9, 12))
      if (secs) {
        return [stime, timeAdd(stime, { s: secs })]
      }
    }
  },

  // 30m@12:30 YYYY-MM-DD
  {
    rx: /^\s*([0-9.]+)\s*([a-z]+)\s*@\s*((\d+):(\d+))\s*((p|a)m?)?\s+(\d{4})-(\d+)-(\d+)\s*$/i,
    fn: (origin, match, _input) => {
      // match [0:"30m@12:30 ...", 1:"30", 2:"m", 3:"12:30", 4:"12", 5:"30", 6:'a', 7:'p', 8:'yyyy', 9:'mm', 10:'dd' ...]
      const date = moment(`${match[8]}-${match[9]}-${match[10]}T00:00:00`).unix()
      // DEBUG(`FN6 (${origin}, ${match}, _)`)
      // expect [string, "hr:mn", "hr", "mn", "am", "a", ...]
      const stime = timeAt(match.slice(2, 6), date)
      // DEBUG(`stime=>${stime}`)
      const secs = durationAsSecondsMatch(match.slice(0, 3))
      // DEBUG(`secs=>${stime}`)
      if (secs) {
        return [stime, timeAdd(stime, { s: secs })]
      }
    }
  },

  // 30m
  {
    rx: /^\s*([0-9.]+)\s*([a-z]+)?\s*$/i,
    fn: (origin, match, _input) => {
      // DEBUG(`FN7 (${origin}, ${match}, _)`)
      const secs = durationAsSecondsMatch(match)
      // DEBUG(`=> ${secs}`)
      if (secs) {
        let ret = [timeAdd(origin, { s: -secs }), origin]
        // DEBUG('returning=> ', ret)
        return ret
      }
    }
  }
]

export default function parseRange(string, origin) {
  try {
    if (!origin) {
      origin = timeNow()
      // DEBUG('no origin, now=>', origin)
    }
    for (let r in RANGES) {
      const test = RANGES[r]
      // DEBUG('parseRange() RANGE', test)
      const match = string.match(test.rx)
      if (match) {
        // DEBUG('parseRange() MATCHED', match)
        const result = test.fn(origin, match, string)
        // DEBUG('parseRange() result!', test, result)
        if (result) {
          const [stime, etime] = result
          // DEBUG('parseRange() inside', stime, etime, (etime - stime))
          const xr = [stime, etime, etime - stime]
          // DEBUG('parseRange() returning=>', xr)
          return xr
        }
      }
    }
  } catch (err) {
    // DEBUG('parseRange error', err)
  }
}

export function formatHumanRange(stime, etime) {
  // DEBUG(`formatRange(${stime}, ${etime})`)
  const duration = secondsForHuman(etime - stime)
  const now = timeNow()
  const today = dayStart(now)
  if (dayStart(stime) === today) {
    // we are within now, just leave it off...
    if (etime - (etime % 60) === now - (now % 60)) {
      return duration
    } else {
      return duration + ' @' + moment.unix(stime).format('hh:mma')
    }
  }
  return duration + ' @' + moment.unix(stime).format('hh:mma YYYY-MM-DD')
}
export function formatIsoRange(stime, etime) {
  const smoment = moment.unix(stime)
  const emoment = moment.unix(etime)
  const fmt = 'YYYY-MM-DDTHH:mm:ssZZ'
  return smoment.format(fmt) + '/' + emoment.format(fmt)
}

export function secondsForHuman(seconds) {
  // DEBUG(`secondsForHuman(${seconds})`)
  if (seconds > 86400) {
    return `${Math.round(seconds / 86400)}d`
  } else if (seconds > 3600) {
    return `${Math.round(seconds / 3600)}h`
  } else {
    return `${Math.round(seconds / 60)}m`
  }
}

// input string, parse hr/min
function timeHrMn(string, origin) {
  // DEBUG(`timeHrMn(${string},${origin})`)
  const ematch = string.match(HRMN)
  if (ematch === undefined) {
    return null
  }
  let etime = timeAt(ematch, origin)
  if (etime) {
    if (etime < origin) {
      etime = timeAdd(etime, { h: 12 })
    }
    return [origin, etime]
  }
}

// expect [string, "hr:mn", "hr", "mn", "am", "a", ...]
function timeAt(match, origin) {
  // DEBUG(`timeAt([${match}], ${origin})`)
  let hr = parseInt(match[2])
  // DEBUG('hr', hr)
  let mn = parseInt(match[3])
  // DEBUG('mn', mn)
  let ampm = match[4]
  // DEBUG('ampm', ampm)
  if (ampm) {
    ampm = ampm.slice(0, 1).toLowerCase()
    if (ampm === 'p') {
      hr += 12
    }
  }
  // DEBUG('origin', origin)
  return timeAdd(dayStart(origin), { h: hr, m: mn })
  //  return moment(origin).startOf('day').add({hours: hr, minutes: mn})
}

// expect "1 day"
function durationAsSecondsString(string) {
  // DEBUG(`durationAsSecondsString(${string})`)
  const match = string.match(DURATION)
  if (match !== null) {
    return durationAsSecondsMatch(match)
  }
}

// expect ["1 day", "1", "day", ...]
function durationAsSecondsMatch(match) {
  // DEBUG(`durationAsSecondsMatch(${match})`)
  let [num, type] = match.slice(1, 3)
  num = parseFloat(num)
  if (!type) {
    type = ''
  }
  for (let r in DURATIONS) {
    const test = DURATIONS[r]
    const match = type.match(test.rx)
    if (match !== null) {
      const result = test.fn(num, match)
      if (result !== undefined) {
        return result
      }
    }
  }
}

// moment is being crazy buggy, where moment(moment_obj) isn't working right
// yay javascript (grr)
function timeAdd(posixTime, adjust) {
  // DEBUG(`timeAdd(${posixTime}, `, adjust)
  for (let key in adjust) {
    switch (
      key // eslint-disable-line
    ) {
      case 's':
        // DEBUG('sec', adjust[key])
        posixTime += adjust[key]
        break
      case 'm':
        // DEBUG('min', adjust[key])
        posixTime += adjust[key] * 60
        break
      case 'h':
        // DEBUG('hour', adjust[key])
        posixTime += adjust[key] * 3600
        break
      case 'd':
        // DEBUG('day', adjust[key])
        posixTime += adjust[key] * 86400
        break
    }
  }
  // DEBUG('timeAdd => ', posixTime)
  return posixTime
}
function dayStart(posixTime) {
  // DEBUG(`dayStart(${posixTime})`)
  const val = moment.unix(posixTime).startOf('day').unix()
  // DEBUG(`=> ${val}`)
  return val
}
function timeNow() {
  return Math.floor(Date.now() / 1000)
}

/*
export function test () {
  console.log("Starting tests")
  const now = timeNow()
  const daystart = dayStart(now)
  const today = moment.unix(now).format("YYYY-MM-DD")
  const today_n1 = moment.unix(daystart-3600).format("YYYY-MM-DD")
  const today_n2 = moment.unix(daystart-86400-3600).format("YYYY-MM-DD")
  const tests = [
    ['1d', { seconds: 86400, checkend: true, sdate: today_n1 }],
    ['2.5 days', { seconds: 216000, checkend: true, sdate: today_n2 }],
    ['2.5h', { seconds: 9000, checkend: true, sdate: today }],
    ['2h', { seconds: 7200, checkend: true, sdate: today }],
    ['20m', { seconds: 1200, checkend: true, sdate: today }],
    ['20min', { seconds: 1200, checkend: true, sdate: today }],
    ['20 min', { seconds: 1200, checkend: true, sdate: today }],
    ['20', { seconds: 1200, checkend: true, sdate: today }],
    ['20s', { seconds: 20, checkend: true, sdate: today }],
    ['120s', { seconds: 120, checkend: true, sdate: today }],
    ['8:45 am', { seconds: 0, checkend: false, sdate: today }],
    ['8:45a', { seconds: 0, checkend: false, sdate: today }],
    ['8:45p', { seconds: 0, checkend: false, sdate: today }],
    ['10:25a+5min', { seconds: 300, checkend: false, sdate: today }],
    ['10:25p + 1 hours', { seconds: 3600, checkend: false, sdate: today }],
    ['10:25a - 14:20', { seconds: 14100, checkend: false, sdate: today }],
    ['30m@12:20', { seconds: 1800, checkend: false, sdate: today }],
    ['50m @ 12:20', { seconds: 3000, checkend: false, sdate: today }],
    ['2019-06-26 10:30p +15m', { seconds: 900, checkend: false, sdate: "2019-06-26", shrmn: "22:30", ehrmn: "22:45" }],
    ['2019-06-26T12:19-0600 +15m', { seconds: 900, checkend: false, sdate: "2019-06-26" }],
    ['2019-06-26T10:30-0600 +15m', { seconds: 900, checkend: false, sdate: "2019-06-26" }],
    ['2019-06-26 T 10:30 -0600 +15m', { seconds: 900, checkend: false, sdate: "2019-06-26" }],
    ['2019-06-26 T 10:30 pm -0600 +15m', { seconds: 900, checkend: false, sdate: "2019-06-26" }],
    ['2019-06-26 11:31am +30m', { seconds: 1800, checkend: false, sdate: "2019-06-26" }],
    ['2019-06-26 09:56am +3.5h', { seconds: 12600, checkend: false, sdate: "2019-06-26" }],
    ['30m@12:20 2019-06-25', { seconds: 1800, checkend: false, sdate: "2019-06-25" }],
  ]

  let origin = timeNow()
  try {
    tests.map(([input, expect]) => {
      console.log("STARTING TEST -----------------------------------------------", input, expect)
      const result = parseRange(input, origin)
      if (result) {
        const [stime, etime, duration] = result // eslint-disable-line
        console.log(`duration=${duration} .. ${etime - stime}`)
        if (duration !== expect.seconds) {
          console.log(`NO MATCH: ${duration} !== ${expect.seconds}`)
          throw ('STOP')
        }
        if (expect.checkend && etime !== origin) {
          console.log('etime', etime, origin)
          throw ('STOP')
        }
        const mstime = moment.unix(stime)
        const msdate = mstime.format("YYYY-MM-DD")
        const metime = moment.unix(etime)
        if (expect.sdate !== msdate) {
          console.log(`msdate, expected=${expect.sdate}, received=${msdate}`)
          throw ('STOP')
        }
        // DRY this out
        if (expect.ehrmn) {
          const metime_s = metime.format("HH:mm")
          if (metime_s !== expect.ehrmn) {
            console.log(`metime, expected=${expect.ehrmn}, received=${metime_s}`)
            throw ('STOP')
          }
        }
        if (expect.shrmn) {
          const mstime_s = mstime.format("HH:mm")
          if (mstime_s !== expect.shrmn) {
            console.log(`mstime, expected=${expect.shrmn}, received=${mstime_s}`)
            throw ('STOP')
          }
        }
      } else {
        console.log(`NO MATCH: == ${result}`)
        throw ('STOP')
      }
    })
  } catch (err) {
    console.log('ERROR', err)
  }
}
*/
