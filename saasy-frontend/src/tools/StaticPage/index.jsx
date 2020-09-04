import React, { useState } from 'react'
import { useParams } from 'react-router-dom'
import axios from 'axios'

function StaticPage(props) {
  const params = useParams()

  const path = [params.p1, params.p2, params.p3].filter((p) => p).join('/')
  // somebody messing around
  if (path.includes('..')) {
    return null
  }

  return <StaticContentDiv path={`${path}.html`} />
}

export function StaticContentDiv({ path, className = 'static' }) {
  const fpath = `/assets/div/${path}`
  const [content, updateContent] = useState('')

  axios.get(fpath).then((res) => updateContent(res.data))
  return (
    <div className={className}>
      <div dangerouslySetInnerHTML={{ __html: content }} />
    </div>
  )
}

export default StaticPage
