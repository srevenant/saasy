import React, { useReducer, createContext } from 'react'
import { v4 as uuid } from 'uuid'

export const POPUP_MESSAGE = 1
export const CLEAR_MESSAGES = 2
export const RESET_MESSAGES = 4
export const REMOVE_MESSAGE = 3

// more readable code externally
export function notify(dispatch, value) {
  dispatch({ type: POPUP_MESSAGE, value: value })
}

export const defaultMessage = {
  id: undefined,
  content: undefined,
  expire: true,
  type: 'warn' // warn and info also configured -- correlates to style scs
}

export const defaultState = []

export const reducer = (state, action) => {
  switch (action.type) {
    case POPUP_MESSAGE:
      return state.concat({ ...defaultMessage, id: uuid(), ...action.value })
    case CLEAR_MESSAGES:
      return state.filter((msg) => !msg.expire)
    case RESET_MESSAGES:
      return []
    case REMOVE_MESSAGE:
      return state.filter((msg) => msg.id !== action.value)
    default:
      throw new Error(`no such action.type: ${action.type}!`)
  }
}

export const NotifyStore = createContext(null)

export function NotifyProvider({ children }) {
  const [state, dispatch] = useReducer(reducer, defaultState)
  return (
    <NotifyStore.Provider value={[state, dispatch]}>
      {children}
    </NotifyStore.Provider>
  )
}

export default NotifyStore
