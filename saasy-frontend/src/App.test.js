import React from 'react'
import ReactDOM from 'react-dom'
import App from './App'

// deal with this later
// @ts-ignore error TS2582: Cannot find name 'it'. Do you need to install type definitions for a test runner? Try `npm i @types/jest` or `npm i @types/mocha`.
it('renders without crashing', () => {
  const div = document.createElement('div')
  ReactDOM.render(<App />, div)
  ReactDOM.unmountComponentAtNode(div)
})
