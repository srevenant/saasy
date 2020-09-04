import React, { useState, useContext, useEffect } from 'react'
import { useHistory } from 'react-router-dom'
import { Controls, ControlIcon } from 'tools/Controls'
import { ProfileContext, ACTIONS } from './resolver'
import { useParams } from 'react-router-dom'
import { Loading } from 'tools/Handlers'
import { FULL_PUBLIC_PERSON } from 'constants/Person'
import Edit from './Edit'
import Show from './Show'
import Store from 'store'

function ViewPanel({ previous = '/connect', editing = false }) {
  const [{ person }] = useContext(ProfileContext)
  const [{ user }] = useContext(Store)
  const [edit, setEdit] = useState(editing)
  const history = useHistory()

  return (
    <div className="theme-frame max-view-page theme-bg-flat w-100">
      <Controls>
        {person.allows(user, 'edit') ? (
          <ControlIcon
            icon={`fas fa-${edit ? 'eye' : 'edit'}`}
            onClick={() => setEdit(!edit)}
          />
        ) : null}
        <ControlIcon icon="fas fa-times" onClick={() => history.push(previous)} />
      </Controls>
      {edit ? <Edit /> : <Show />}
    </div>
  )
}

function Lookup({ handle, id, className = 'w-100 mv4', ...args }) {
  const [target, setTarget] = useState('')
  const [loading, setLoading] = useState(false)
  const [{ apollo }] = useContext(Store)
  const [{ person, error }, dispatch] = useContext(ProfileContext)

  const needLoad = (handle || id) !== target
  useEffect(() => {
    if (!loading && needLoad) {
      setLoading(true)
      setTarget(handle || id)
      apollo
        .query({
          query: FULL_PUBLIC_PERSON,
          variables: { target: handle, id: id }
        })
        .then(
          ({
            data: {
              publicPerson: { success, result, reason }
            }
          }) => {
            setLoading(false)
            if (success) {
              dispatch({ type: ACTIONS.SET_PERSON, value: result })
            } else {
              dispatch({ type: ACTIONS.MERGE, value: { error: reason } })
            }
          }
        )
    }
  }, [loading, needLoad, apollo, handle, id, dispatch, target])

  if (!needLoad && !loading && person && person._real) {
    return (
      <div className={className}>
        <ViewPanel {...args} />
      </div>
    )
  }
  return loading || needLoad ? (
    <Loading />
  ) : (
    <div className="flex-center h-100 v-100 f3">
      Sorry!{' '}
      {error ? (
        error
      ) : (
        <>
          We are unable to find{' '}
          {handle ? <span className="fw3 ml2 i">~{handle}</span> : 'that person'}
        </>
      )}
    </div>
  )
}

function Profile({ id = undefined, ...args }) {
  const { user } = useParams()
  // <ProfileProvider>
  return <Lookup handle={user} id={id} {...args} />
  // </ProfileProvider>
}

export default Profile
