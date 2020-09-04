import React from 'react'
import ReactDOM from 'react-dom'
import './styles/index.scss'
import App from './App'
import * as serviceWorker from 'utils/serviceWorker'
import config from 'constants/config'
import { StoreProvider as GlobalProvider } from 'store'
import { ProfileProvider } from 'components/Social/Profile/resolver'
import { NotifyProvider } from 'tools/Notify/resolver'

console.log(`BUILD=${config.build} APP=${config.baseurl}`)

// only include high level providers and configuration things here
ReactDOM.render(
  <GlobalProvider>
    <ProfileProvider>
      <NotifyProvider>
        <App />
      </NotifyProvider>
    </ProfileProvider>
  </GlobalProvider>,
  document.getElementById('root')
)

serviceWorker.unregister()
