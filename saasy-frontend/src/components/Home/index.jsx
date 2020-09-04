import React, { useContext } from 'react'
import Store, { usePage } from 'store'

function Home() {
  usePage({ name: 'Home', background: 'flat' })
  // const [{ page }] =
  useContext(Store)
  return (
    <div>
      Hello World
    </div>
  )
}
export default Home
