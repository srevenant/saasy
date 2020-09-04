import React, { useReducer, createContext, useContext, useEffect } from 'react'

import apollo from '../apollo'

import {
  authDropStates,
  authRequest,
  authXinitialState,
  AUTHX_ACTIONS
} from 'utils/authx'
import { normalizeUser, normalizeUserParam, defaultUser } from 'utils/user'
import { randomBackground } from 'constants/backgrounds'

export const USER_CLICKED = 'user_clicked'
export const RESET_APOLLO = 'reset_apollo'
export const SET_BROWSE_UNI = 'set_browse_uni'
export const SET_BROWSE_COST_DIST = 'set_browse_cost_dist'
export const SET_INTERFACE_CONFIG = 'set_interface_config'
export const SET_USER = 'set_user'
export const USER_IDENTIFIED = 'user_identified'
export const MERGE_USER = 'merge_user'
export const MERGE = 'merge'
export const SET_TAGS = 'SET_TAGS'
// todo: shift to a grouped convention like this, beginning with R_{thing} (resolver)
export const R_PREFS = {
  SET: 101,
  READY: 102
}
export const R_PAGE = {
  SET: 0
}

// usePage({name}) - only used for top-levels, not every discrete page
// usePage({background}) - image|flat - how to display the page
// usePage({image}) - image used on background, don't change this
export function usePage(args) {
  const [{ page }, dispatch] = useContext(Store)

  const needsChange = Object.keys(args).reduce(
    (need, key) => need || page[key] !== args[key],
    false
  )
  useEffect(() => {
    if (needsChange) {
      dispatch({ type: R_PAGE.SET, value: args })
    }

    // disabled because I don't need it triggering when args is different -BJG
    // eslint-disable-next-line
  }, [needsChange, dispatch])
}

////////////////////////////////////////////////////////////////////////////////
export function useDelay(key) {
  const [{ prefs }, dispatch] = useContext(Store)
  useEffect(() => {
    if (prefs.skip === false) {
      return
    }
    let isMounted = true
    setTimeout(() => {
      if (isMounted) {
        dispatch({ type: R_PREFS.READY })
      }
    }, 400)
    // return the function to "unmount"
    return () => (isMounted = false)
  }, [prefs.skip, dispatch])
}

////////////////////////////////////////////////////////////////////////////////
const initialState = {
  apolloInit: false,
  prefs: {
    projectList: {
      stages: [],
      ask: 'any',
      needs: [],
      files: [],
      activity: 'quarter',
      name: ''
    },
    projectList_t: 0,
    connect: {
      name: '',
      skills: [],
      types: [],
      roles: []
    },
    connect_t: 0,
    skip: true
  },
  page: {
    image: randomBackground(),
    background: 'flat'
  },
  history: [window.location.pathname],
  apollo: apollo(() => {}),
  interfaceConfig: {},
  user: defaultUser(),
  authx: authXinitialState()
}

function signOut(state, authx) {
  authDropStates()
  state.apollo.cache.reset()
  const revised = {
    ...state,
    authx,
    history: [window.location.pathname],
    user: defaultUser(),
    apollo: apollo(() => {}),
    apolloInit: false
  }
  authRequest('signout', {})
  return revised
}

function reducer(state, { type, ...action }) {
  switch (type) {
    case RESET_APOLLO:
      return { ...state, apolloInit: true, apollo: apollo(action.dispatch) }

    case SET_INTERFACE_CONFIG:
      return { ...state, interfaceConfig: action.value }

    // authx
    case AUTHX_ACTIONS.SIGNING_IN:
      return {
        ...state,
        authx: {
          ...authXinitialState(),
          targetAuthed: true,
          isAuthN: false,
          handshaking: true,
          error: undefined
        }
      }

    case AUTHX_ACTIONS.SIGN_OUT:
      if (state.authx.isAuthN) {
        return signOut(state, { ...authXinitialState() })
      }
      return state

    case AUTHX_ACTIONS.ERROR_CLEAR:
      return {
        ...state,
        authx: {
          ...state.authx,
          error: undefined
        }
      }

    case AUTHX_ACTIONS.ERROR:
      return {
        ...state,
        authx: {
          ...state.authx,
          handshaking: false,
          isAuthN: false,
          refresh: false,
          error: action.value
        }
      }

    case AUTHX_ACTIONS.SIGNED_IN:
      return {
        ...state,
        authx: {
          ...state.authx,
          refresh: false,
          isAuthN: true,
          handshaking: false,
          error: undefined
        }
      }

    case AUTHX_ACTIONS.REFRESH_TOKEN:
      return {
        ...state,
        authx: {
          ...state.authx,
          refresh: action.value
        }
      }

    case USER_IDENTIFIED:
      // identified but not authenticated
      let newstate = state
      if (state.user.authStatus !== 'unknown') {
        // full reset
        newstate = signOut(state)
      } else {
        newstate = { ...defaultUser() }
      }

      // going from unknown to identified we can keep the cached info
      // so just set the profile needs to be loaded, and <App> will pick it up
      return { ...newstate, user: { ...newstate.user } }

    case SET_USER:
      return { ...state, user: normalizeUser(action.value, true) }

    case SET_TAGS:
      return {
        ...state,
        user: {
          ...state.user,
          profile: action.value,
          ...normalizeUserParam('profile', action.value)
        }
      }

    case MERGE_USER:
      // general purpose tool
      return { ...state, user: { ...state.user, ...action.value } }

    case MERGE:
      // bigger swiss army knife
      return { ...state, ...action.value }

    case R_PREFS.SET:
      // note: _t is so we can do delayed queries by knowing when the last change was
      return {
        ...state,
        prefs: {
          ...state.prefs,
          [action.key]: { ...state.prefs[action.key], ...action.value },
          [action.key + '_t']: new Date().getTime(),
          skip: true
        }
      }

    case R_PREFS.READY:
      return { ...state, prefs: { ...state.prefs, skip: false } }

    case R_PAGE.SET:
      return {
        ...state,
        page: { ...state.page, ...action.value }
      }

    case USER_CLICKED:
      if (action.value === state.history[state.history.length - 1]) {
        return state
      }

      return {
        ...state,
        history: state.history.concat(action.value)
      }

    default:
      throw new Error(`no such action.type: ${type}!`)
  }
}

export const Store = createContext(null)
export const StoreProvider = ({ children }) => {
  const [state, dispatch] = useReducer(reducer, initialState)
  return <Store.Provider value={[state, dispatch]}>{children}</Store.Provider>
}

export default Store
