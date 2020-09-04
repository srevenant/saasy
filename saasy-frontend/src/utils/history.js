const debug = (x, y) => {}

export const LAST_NAV = 'pf-nav'

export function lastNav() {
  debug('[NavBar].lastNav()', '')
  return localStorage.getItem(LAST_NAV)
}

export function navigate(history, dst) {
  debug('[history].navigate(h, dst) dst=', dst)

  let to = dst
  if (to === undefined) {
    to = '/'
  }

  history.push(to || '/')
}

// this is just for readability
export const navigateBackwards = navigate
