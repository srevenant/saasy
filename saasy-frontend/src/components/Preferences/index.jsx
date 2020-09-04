import React, { useState, useContext } from 'react'
import { UPDATE_PERSON } from 'constants/Person'
// import handleWait from 'tools/Handlers'
import { useMutation } from 'react-apollo'
import { useParams } from 'react-router-dom'
import Settings from './Settings'
import Profile from 'components/Social/Profile'
import { ChangePassword } from './PasswordReset'
import NavTabs, { prepTabs } from 'tools/NavTabs'
import Store, { SET_USER } from 'store'

const TABS = prepTabs([
  {
    name: 'Settings',
    tok: 'settings'
  },
  {
    name: 'Profile',
    tok: 'profile'
  },
  {
    name: 'Password',
    tok: 'pwd'
  }
  // {
  //   name: 'APIkey',
  //   tok: 'apikey'
  // }
])

function Prefs() {
  const [state, dispatch] = useContext(Store)
  const [updatePersonMutation] = useMutation(UPDATE_PERSON)

  const settings = state.user.settings

  const makeChange = (vars, next) => {
    vars.id = state.user.id
    updatePersonMutation({
      variables: vars,
      update(cache, { data: { updatePerson } }) {
        if (updatePerson.success) {
          dispatch({
            type: SET_USER,
            value: updatePerson.result
          })
        }

        if (next) {
          next(updatePerson)
        }
      }
    })
  }
  const keyChange = (ev, vars, next) => {
    if (ev.key === 'Enter') {
      ev.preventDefault()
      makeChange(vars, next)
    }
  }

  const changeSettings = (settings) => {
    makeChange({ settings: JSON.stringify(settings) })
  }

  const params = useParams()
  const [activeTab, setActiveTab] = useState(
    params.tab ? TABS.d[params.tab].x : 0
  )
  const curtab = TABS.l[activeTab]

  const pargs = {
    settings,
    changeSettings,
    makeChange,
    keyChange,
    user: state.user
  }

  if (state.user.isIdentified) {
    return (
      <NavTabs base="/prefs" tabs={TABS} tabState={[activeTab, setActiveTab]}>
        <div className="mh1-ns mh3-m mh4-l mt3-ns mt4-l flex-l mb6 max-view-page w-100">
          {curtab.tok === 'settings' ? (
            <Settings {...pargs} />
          ) : curtab.tok === 'profile' ? (
            <Profile id={state.user.id} className="w-100" editing={true} />
          ) : curtab.tok === 'pwd' ? (
            <PasswordChanger settings={settings} />
          ) : null}
        </div>
      </NavTabs>
    )
  } else {
    return null
  }
}

function PasswordChanger(props) {
  return (
    <div className="w-100 theme-frame theme-bg-flat">
      <div className="theme-bg-accent br2 pv1 pv2-ns ph2 ph3-l tl w-100 f6 b mr2 flex justify-between">
        <div>CHANGE PASSWORD</div>
      </div>
      <div className="flex justify-center">
        <div className="ph1 ph2-m ph3-l w-100 ba b--transparent pb3 pt3 w-50-l w-75-m">
          <ChangePassword inputCode={null} {...props} />
        </div>
      </div>
    </div>
  )
}

export default Prefs
