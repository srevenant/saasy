import React, { useState, useEffect } from 'react'
import FuzzBox from 'deprecate/FuzzBox'
import { loadingBabble } from 'utils/loadingBabble'

export function handleWaitForLoad({ loading, error }) {
  if (loading) {
    return <LoadingOverlay onlyFull={true} />
  }
  if (error) {
    return <ErrorBox>{readableError(error)}</ErrorBox>
  }
  return null
}

export function handleWaitForLoadInline({ loading, error }) {
  if (loading) {
    return <LoadingInline />
  }
  if (error) {
    return <ErrorBox>{readableError(error)}</ErrorBox>
  }
  return null
}

export function LoadingInline(props) {
  return (
    <div className="flex">
      {props.children || loadingBabble()}
      <div className="loading-inline" />
    </div>
  )
}

export function Loading({ children = undefined }) {
  return (
    <div className="flex-center h-100 v-100">
      <div className="flex">
        {children || loadingBabble()}
        <div className="loading-inline" />
      </div>
    </div>
  )
}

// for when loading may take longer
export function LoadingOverlay(props) {
  const { children, onlyFull } = props
  const [showFull, updateShowFull] = useState(false)
  const [retries, updateRetries] = useState(0)
  const showText = (
    <div>
      {children || loadingBabble()}
      {retries ? ' (retry ' + retries + ')' : null}
    </div>
  )

  // DOC: this effect tracks a mount/unmount flag, so it does not update
  // state if the component is not active (mounted)
  useEffect(() => {
    let isMounted = true
    setTimeout(() => {
      if (isMounted) {
        updateShowFull(true)
      }
    }, 300)
    setTimeout(() => {
      if (isMounted) {
        updateShowFull(false)
        updateRetries(retries + 1)
      }
    }, 10000)

    // return the function to "unmount"
    return () => (isMounted = false)
  })

  if (showFull) {
    return (
      <div className="loading-overlay">
        <div className="loading"></div>
        <div className="tc pv2 pv4-m pv6-l white">{showText}</div>
        <div className="loading-body"></div>
      </div>
    )
  } else {
    if (onlyFull) {
      return <></>
    }
    return (
      <div className="flex">
        {showText}
        <div className="loading-inline" />
      </div>
    )
  }
}

// note: something isn't working right in this parsing, it's getting called twice,
// the first time it matches, the second time it comes back null, grr
function matchError({
  graphQLErrors,
  networkError,
  operation,
  forward,
  message
}) {
  return message
}
export function errorString(err) {
  let message = matchError(err)
  if (message) {
    return message
  } else {
    message = err.toString()
    if (message) {
      return message
    } else {
      return 'Unexpected error, please try again in a few minutes'
    }
  }
}
export function readableError(err) {
  const backend =
    'Unexpected response from backend, cannot continue, please try again in a few minutes'
  const message = errorString(err)
  return message
    .replace(/Network error: Unexpected token P in JSON at position 0/, backend)
    .replace(/^.*Unexpected token < in JSON .*$/, backend)
    .replace(/^.*Failed to fetch.*$/, backend)
    .replace(/^Network error: /, '')
    .replace(/Server /i, 'backend ')
    .replace(/GraphQL error: /i, '')
}

export function ErrorBox(props) {
  return (
    <div className="flex justify-center">
      <FuzzBox tint="light" className="tc pa3 black">
        {readableError(props.children)}
      </FuzzBox>
    </div>
  )
}
