import React from 'react'

export const VALIDATION_KEY = 'rtv' // + config.config.lane
export const ACCESS_KEY = 'rta' // + config.config.lane

// eventually query the backend for this
export const TENANT = {
  heading: (
    <div className="pt2 pt4-ns white">
      <div className="pa3 flex-center">
        <div className="pa3 f2 lh-copy fw5 tc text-outline">
          <img src="/assets/img/saasy-logotext-darkbg.svg" alt="saasy" />
        </div>
      </div>
      <div className="flex-center flex-column mb3 mb5-ns">
        <div className="pa3 tc i b f4">
          <div className="mb2">INNOVATION CENTER</div>
        </div>
      </div>
    </div>
  ),
  terms: (
    <div className={`f7 tc mt2`}>
      <i>
        By using this account you agree to our{' '}
        <a href="/#/info/notes">Privacy and Use Policy</a>
      </i>
    </div>
  ),
  passport_info: false,
  background: {
    type: 'random-picture'
  },
  federated: {
    google: {
      enabled: false,
      appId:
        ''
    }
  }
}
