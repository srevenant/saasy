import React, { Suspense, useEffect, useContext } from 'react'
import { ApolloProvider } from 'react-apollo'
import { BrowserRouter as Router, Switch, Route } from 'react-router-dom'

import Footer from 'components/Root/Footer'
import NavBar from 'components/Root/NavBar'
import Background from 'components/Root/Background'
import Prefs from 'components/Preferences'
import PasswordReset from 'components/Preferences/PasswordReset'
import { LoadingOverlay } from 'tools/Handlers'
import Home from 'components/Home'
import AuthX from 'components/AuthX'
// import config from 'constants/config'
import Store, { SET_USER, RESET_APOLLO } from 'store'
import NotifyStore, { notify } from 'tools/Notify/resolver'
import { refreshToken, AUTHX_ACTIONS } from 'utils/authx'
import { READ_SELF } from 'constants/Person'

export function App() {
  const [state, dispatch] = useContext(Store)
  const [, notifyDispatch] = useContext(NotifyStore)

  // initialize apollo
  useEffect(() => {
    if (!state.apolloInit) {
      dispatch({ type: RESET_APOLLO, dispatch })
    }
  }, [state.apolloInit, dispatch])

  // Load user, refetch when we are able to do so (have a validation token)
  const { isAuthN, refresh } = state.authx
  useEffect(() => {
    if (refresh) {
      refreshToken(dispatch)
    }
  }, [refresh, dispatch])

  // Fetch profile after done signing in
  useEffect(() => {
    if (isAuthN) {
      state.apollo
        .query({ query: READ_SELF, fetchPolicy: 'network' })
        .then(({ data: { self } }) => {
          dispatch({ type: SET_USER, value: self })
        })
    }
  }, [isAuthN, state.apollo, dispatch])

  // convert authx errors to notify
  const authx_error = state.authx.error
  useEffect(() => {
    if (authx_error) {
      notify(notifyDispatch, { content: authx_error })
      dispatch({ type: AUTHX_ACTIONS.ERROR_CLEAR })
    }
  }, [authx_error, dispatch, notifyDispatch])

  const theme = `theme-${state.user.settings.theme || 'dark'}`
  useEffect(() => {
    document.body.classList.remove('theme-dark')
    document.body.classList.remove('theme-light')
    document.body.classList.add(theme)
  }, [theme])

  return (
    <ApolloProvider client={state.apollo}>
      <Router>
        <div className="body">
          <Background />
          <Switch>
            <Route exact path="/">
              <Home />
            </Route>
            <Route path="/signon">
              <AuthX signout={false} />
            </Route>
            <Route path="/signout">
              <AuthX signout={true} />
            </Route>
            <Route path="/pwreset">
              <Suspense fallback={<LoadingOverlay />}>
                <PasswordReset />
              </Suspense>
            </Route>
            {state.user.isIdentified ? (
              <>
                <Route path="/prefs/:tab?">
                  <Suspense fallback={<LoadingOverlay />}>
                    <Prefs />
                  </Suspense>
                </Route>

                {state.user.can('auth_admin') ? (
                  <>
                  </>
                ) : null}
              </>
            ) : null}
          </Switch>
          <NavBar />
        </div>
        <Footer />
      </Router>
    </ApolloProvider>
  )
}

export default App
