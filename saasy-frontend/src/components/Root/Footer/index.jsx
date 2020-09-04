import React from 'react'
import { Link } from 'tools/Links'
import style from './index.module.scss'

// theme-bg could be put in here, but it looks odd
function Footer(props) {
  return (
    <div className={`footer ${style.footer} pa3`}>
      <div className="flex-center flex-column mt5 pa2 b mb4">
        <div className="flex items-center items-start-ns flex-column flex-row-ns justify-around-ns w-100 w-50-l f6">
          <div className="mb1">
            <Link to="/d/about">About us</Link>
          </div>
          <div className="mb1">
            <Link to="/d/tos" logOrigin="FooterTerms">
              Terms of Use
            </Link>
          </div>
          <div className="mb1">
            <Link to="/d/tos" logOrigin="FooterPrivacy">
              Privacy Policy
            </Link>
          </div>
        </div>
        <div className="flex items-center justify-center gray mb4 mt4 f6">
          <div className="f6">
            <Link
              to="/d/tos/"
              logOrigin="FooterCopyright"
              className="flex items-center"
            >
              <img
                src="/assets/img/saasy-logotext-darkbg.svg"
                alt="saasy"
                style={{ height: '1rem' }}
                className="mr2 logo"
              />
              &copy; 2020, &trade; Protos, LLC
            </Link>
          </div>
        </div>
      </div>
    </div>
  )
}

export default Footer
