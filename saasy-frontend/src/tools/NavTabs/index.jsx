import React from 'react'
import { useHistory } from 'react-router-dom'
import Scrollbar from 'tools/Scrollbar'
import style from './index.module.scss'

export function prepTabs(lst) {
  return {
    d: lst.reduce((acc, tab) => {
      acc[tab.tok] = tab
      return acc
    }, {}),
    l: lst.map((col, x) => {
      col.x = x
      return col
    })
  }
}

function NavTabs(props) {
  const { tabs, scroll, bg } = props
  let { scrollClasses } = props
  if (!scrollClasses) {
    scrollClasses = ''
  }
  const [activeTab, setActiveTab] = props.tabState
  const history = useHistory()
  // tabs.idx = props.pickCurrent ? props.pickCurrent(tabs, history) : activeTab
  // tabs.tok = tabs.l[activeTab].tok
  let margins = 'mh1-ns mh3-m mh4-l mt3-ns mt4-l'
  if (scroll === 'none') {
    margins = ''
  }

  const tabsJsx = (
    <div className={margins}>
      <div
        className={`${style.tabs} w-100 justify-center theme-frame navbar-bg`}
        style={{ border: 'none' }}
      >
        <div className="flex justify-between">
          {tabs.l.map((tab) => (
            <div
              key={tab.x}
              className={`${style.tab} w-100 pa1 pa2-m pa2-l ${
                activeTab === tab.x
                  ? `${style.active} ba br2 b--primary theme-bg-flat`
                  : ''
              } f7 f6-l f6-m hover-hilight`}
              onClick={(e) => {
                e.preventDefault()
                history.push(props.base + '/' + tab.tok)
                setActiveTab(tab.x)
              }}
            >
              {tab.name}
            </div>
          ))}
        </div>
      </div>
    </div>
  )

  switch (scroll) {
    case 'outer':
      return (
        <>
          {tabsJsx}
          <Scrollbar className={`scroll2 pb5 ${scrollClasses}`}>
            <div className={`mh1-ns mh3-m mh4-l mt2 ${bg ? bg : ''}`}>
              {props.children}
            </div>
          </Scrollbar>
        </>
      )
    case 'inner':
      return (
        <>
          {tabsJsx}
          <div className={`mh1-ns mh3-m mh4-l mt2 ${bg ? bg : ''}`}>
            <Scrollbar className={`scroll1h pb5 ${scrollClasses}`}>
              {props.children}
            </Scrollbar>
          </div>
        </>
      )
    case 'inner-none':
      return (
        <>
          {tabsJsx}
          <div className={`mh1-ns mh3-m mh4-l mt2 ${bg ? bg : ''}`}>
            {props.children}
          </div>
        </>
      )
    default:
      return (
        <>
          {tabsJsx}
          {props.children}
        </>
      )
  }
}

export default NavTabs
