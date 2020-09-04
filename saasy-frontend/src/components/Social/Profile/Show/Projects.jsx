import React from 'react'
import { useHistory } from 'react-router-dom'
import { Avatar } from '../Label'
import { fromNowShort } from 'utils/time'

function Projects({ person }) {
  const history = useHistory()
  if (!person || !person.projects) return null
  return (
    <>
      <label className="heading mt4 mb3">Reactors</label>
      {person.projects.map((p) => {
        const project = p.project
        if (project.status !== 'public') {
          return null
        }
        return (
          <div
            key={p.id}
            className="flex items-center hover-hilight pointer  br3"
            onClick={() => {
              history.push(`/r/${project.shortId}`)
            }}
          >
            <Avatar person={p.project} />
            <div className="ml3 fw2 i">{fromNowShort(p.project.updatedAt)}</div>
            <div className="ml3 ">{p.project.stage}</div>
            <div className="ml3">
              <b>{p.project.title}</b> &mdash; <i>{p.project.subtitle}</i>
            </div>
          </div>
        )
      })}
    </>
  )
}

export default Projects
