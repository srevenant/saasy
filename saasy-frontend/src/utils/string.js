export function capitalize(str) {
  return str[0].toUpperCase() + str.slice(1)
}

// doesn't belong here, oh well
export function intcmp(a, b) {
  return a > b ? -1 : a === b ? 0 : 1
}

export function boolcmp(a, b) {
  return a === b ? 0 : -1
}

export function strcmp(a, b) {
  return a.localeCompare(b, 'en', {
    sensitivity: 'base',
    numeric: 'true'
  })
}

const pgMax = 2147483646
export function inputAsInt(input) {
  let cvalue = `${input.replace(/[^0-9]/g, '')}`
  if (cvalue === '') {
    cvalue = '0'
  }
  let value = parseInt(cvalue)
  if (value >= pgMax) {
    value = pgMax
  }
  return { value }
}

export function plural(number, label) {
  return `${number || 0} ${label}${number !== 1 ? 's' : ''}`
}

export function sizeOf(bytes) {
  if (bytes > 1024 * 1024 * 1024) {
    return `${Math.floor(bytes / 1024 / 1024 / 1024)} Gb`
  } else if (bytes > 1024 * 1024) {
    return `${Math.floor(bytes / 1024 / 1024)} Mb`
  } else if (bytes > 1024) {
    return `${Math.floor(bytes / 1024)} Kb`
  } else {
    return `${bytes} b`
  }
}
