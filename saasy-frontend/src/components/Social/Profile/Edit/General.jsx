import React, { useContext } from 'react'
import { InputInline } from 'tools/InputInline'
import Toggle from 'tools/Toggle'
import AvatarEditView from '../Picture'
import ProfileContext, { ACTIONS } from '../resolver'
import Store from 'store'
import ThemeToggle from 'components/Preferences/ThemeToggle'

function General(props) {
  const [{ user }] = useContext(Store)
  const [, dispatch] = useContext(ProfileContext)
  const { person, onSave } = props

  // interfacing back to the way Preferences/Settings wants it
  const makeChange = (vars) => onSave({ tok: 'settings' }, vars.settings)

  return (
    <div className="pa4 max-view-page">
      <div className="flex items-center pt4">
        <AvatarEditView
          origin={person}
          type="user"
          onSave={(v) =>
            dispatch({ type: ACTIONS.SET_PERSON_PARAM, value: ['avatar', v] })
          }
          canEdit={true}
        />
        {user.id === person.id ? (
          <div className="ml4">
            <ThemeToggle
              settings={user.settings}
              makeChange={makeChange}
              className=""
            >
              This site supports a dark and a light theme, which you can switch
              between.
            </ThemeToggle>
          </div>
        ) : null}
      </div>

      <FormInput {...props} label="Name" tok="name" hide={false} />
      <FormInput {...props} label="Handle" tok="handle" hide={false} />
      <FormInput
        {...props}
        hide={false}
        label="About You"
        tok="desc"
        placeholder="A few words describing yourself"
      />
      <FormInput {...props} label="City" tok="city" />
      <FormInput {...props} label="State" tok="state" />
    </div>
  )
}

function FormInput({
  label,
  tok,
  hide = true,
  placeholder = undefined,
  person,
  form,
  onSave,
  toggleSave,
  chgForm
}) {
  const hide_tok = hide ? 'hide_' + tok : ''
  return (
    <>
      <div className="mt4 mb2">
        <label className="heading f6 b db">{label}</label>
      </div>
      <div className="flex">
        <InputInline
          placeholder={placeholder || label}
          value={form[tok]}
          valState={[form[tok] || '', (v) => chgForm(tok, v)]}
          onSave={onSave}
          tok={tok}
          className="w-100"
        />
        {hide ? (
          <div className="tc">
            <div className="f7 tc b gray">hide</div>
            <Toggle
              onChange={(v) => toggleSave(hide_tok, v)}
              value={person.toggles[hide_tok]}
            />
          </div>
        ) : null}
      </div>
    </>
  )
}

export default General
