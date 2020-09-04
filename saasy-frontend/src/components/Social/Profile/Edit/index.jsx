import React, { useContext, useCallback } from 'react'
import { useMutation } from 'react-apollo'
import Store from 'store'
import ProfileContext, { ACTIONS } from '../resolver'
import { UPDATE_PERSON } from 'constants/Person'
import General from './General'
import { genSavePerson } from './lib'

////////////////////////////////////////////////////////////////////////////////
// TODO: add hook for user== and global dispatch
function Edit() {
  const [{ person, form }, pdispatch] = useContext(ProfileContext)
  const [{ user }, gdispatch] = useContext(Store)

  const chgForm = (key, value) => {
    pdispatch({ type: ACTIONS.SET_FORM_PARAM, value: { [key]: value } })
  }

  // / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / /
  const [mutate] = useMutation(UPDATE_PERSON)
  const context = { pDisp: pdispatch, gDisp: gdispatch, myId: user.id }
  const onSave = useCallback(genSavePerson(person, mutate, context), [
    person,
    mutate,
    context
  ])

  const toggleSave = (key, v) => {
    chgForm(key, v)
    onSave({ tok: key }, v)
  }

  // / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / /
  // const sstyle = selectStyle(user)
  // user.isMe = true

  const props = { onSave, toggleSave, chgForm, person, form }
  return (
    <div>
      <General {...props} />
    </div>
  )
}

export default Edit
