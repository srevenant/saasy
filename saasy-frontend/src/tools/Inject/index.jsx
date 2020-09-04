import React, { useState } from 'react'
import axios from 'axios'

export default function Inject({ path }) {
  const [content, updateContent] = useState('')

  axios.get(`/assets/div/${path}`).then((res) => {
    updateContent(res.data)
  })
  return <div dangerouslySetInnerHTML={{ __html: content }} />
}
