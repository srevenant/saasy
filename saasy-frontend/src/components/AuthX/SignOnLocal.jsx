/*
 Authentication View.
*/

import React, { useState, useContext } from 'react'
import style from './SignOnLocal.module.scss'
import { doSignOnLocal } from './doSignOnLocal'
import StatusBox from './StatusBox'
import Store from '../../store'

////////////////////////////////////////////////////////////////////////////////
export function SignOnLocal({ boxPadding, className = '' }) {
  const [state, dispatch] = useContext(Store)
  const [status, setStatus] = useState('')
  const tabHeaders = [
    { txt: 'Sign In', tok: 'signin' },
    { txt: 'Sign up', tok: 'signup' }
  ]
  const tabHeadersMap = tabHeaders.reduce((map, item) => {
    map[item.tok] = item
    return map
  }, {})
  const [currentTab, setCurrentTab] = useState('signin')

  const tabClick = (item, index, event) => {
    event.preventDefault()
    setStatus('')
    setCurrentTab(tabHeaders[index].tok)
  }

  let handle
  let password

  return (
    <div className={style.tabs}>
      <div className={`${style.tabList}`}>
        {tabHeaders.map((item, index) => {
          return (
            <div
              onClick={(e) => tabClick(item, index, e)}
              className={`${style.tab} ${
                item.tok === currentTab ? style.selected : ''
              }`}
              key={index}
            >
              {item.txt}
            </div>
          )
        })}
      </div>
      <div className={`${boxPadding} ${style.tabPanel} pb1`}>
        <div className={`pt3 pt4-ns items-center`}>
          <form>
            <input
              ref={(node) => {
                handle = node
              }}
              className="w-100 br2"
              placeholder="Your email"
            />
            <input
              ref={(node) => {
                password = node
              }}
              className="w-100 br2 mt3"
              type="password"
              placeholder={
                'Your ' + (currentTab === 'signup' ? 'desired ' : '') + 'password'
              }
            />

            <div className="flex justify-around mt3 items-center">
              <button
                className={`button auth-signin ${style.signinButton} w-100 items-center pa2`}
                style={{ border: 0, margin: 0 }}
                onClick={(e) => {
                  e.preventDefault()
                  setStatus('')
                  doSignOnLocal({
                    state,
                    signup: currentTab,
                    status: { status, setStatus },
                    handle,
                    password,
                    dispatch
                  })
                }}
              >
                <small className="label pl2">
                  {tabHeadersMap[currentTab].txt}
                </small>
              </button>
            </div>
            <StatusBox message={status} />
          </form>
        </div>
      </div>
    </div>
  )
}

export default SignOnLocal
