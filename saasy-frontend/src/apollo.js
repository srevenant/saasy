import { ApolloLink } from 'apollo-link'
import { ApolloClient } from 'apollo-boost'
import { InMemoryCache } from 'apollo-cache-inmemory'
import { createHttpLink } from 'apollo-link-http'
import { onError } from 'apollo-link-error'
import { setContext } from 'apollo-link-context'
import {
  refreshToken,
  getAccessToken,
  setAccessToken,
  authError,
  AUTHX_ACTIONS
} from 'utils/authx'
import { fromPromise } from 'apollo-link'

import { readableError } from 'tools/Handlers'
import config from 'constants/config'
import debug from 'utils/debug'

export const httpLink = createHttpLink({
  uri: config.baseurl + config.graphql,
  // I prefer this is 'include' but httpLink returns a network error in prod
  // if this is the setting.  something to look into later...
  // credentials: 'same-origin'
  credentials: 'include'
})

// some state management to pause execution while we refresh tokens
let IS_REFRESHING = false
let PENDING_REQUESTS = []
function pendingRequestsCallback() {
  debug('[apollo:errorLink] updating local cycle')
  PENDING_REQUESTS.map((callback) => callback())
  PENDING_REQUESTS = []
}
function pendingRequestsResolve(resolve) {
  PENDING_REQUESTS.push(() => resolve())
}
function handleError(error, dispatch) {
  debug('[apollo:errorLink] error updating', error)
  PENDING_REQUESTS = []
  authError({ dispatch, msg: readableError(error) })
}
function finishResolving() {
  IS_REFRESHING = false
}

export function apollo(dispatch) {
  const authLink = setContext(async (_, { headers }) => {
    const { token } = getAccessToken(dispatch)
    // const { token, expires } = getAccessToken(dispatch)
    // debug(
    //   '[apollo] authLink',
    //   token
    //     ? `(authed) expires in ${(expires - Date.now()) / 1000} s`
    //     : '(unauth)'
    // )
    return {
      headers: {
        ...headers,
        authorization: token ? `Bearer ${token}` : ''
      }
    }
  })

  const errorLink = onError(
    ({ graphQLErrors, networkError, operation, forward }) => {
      debug('[apollo:errorLink]', [graphQLErrors, operation, forward])

      if (graphQLErrors) {
        for (let err of graphQLErrors) {
          switch (err.message) {
            case 'permission denied':
            case 'Unauthenticated':
            case 'Unauthorized':
            case 'Error: GraphQL error: permission denied':
            case 'GraphQL error: permission denied':
              let forward$
              setAccessToken(null)
              if (!IS_REFRESHING) {
                IS_REFRESHING = true
                debug('[apollo:errorLink] intercepting and refreshing token')

                forward$ = fromPromise(
                  refreshToken(dispatch)
                    .then(({ access_token: fresh_token }) => {
                      if (fresh_token) {
                        const headers = operation.getContext().headers
                        operation.setContext({
                          headers: {
                            ...headers,
                            authorization: `Bearer ${fresh_token}`
                          }
                        })
                        pendingRequestsCallback()
                      } else {
                        dispatch({ type: AUTHX_ACTIONS.SIGN_OUT })
                      }
                    })
                    .catch((error) => handleError(error, dispatch))
                    .finally(finishResolving)
                )
              } else {
                // Will only emit once the Promise is resolved
                forward$ = fromPromise(new Promise(pendingRequestsResolve))
              }

              return forward$.flatMap(() => forward(operation))

            default:
              debug('[apollo] errorLink: unrecognized error', err)
          }
        }
      }

      if (networkError) {
        console.log(`[Network error]: ${networkError}`)
      }
    }
  )

  return new ApolloClient({
    link: ApolloLink.from([authLink, errorLink, httpLink]),
    cache: new InMemoryCache()
  })
}

export default apollo
