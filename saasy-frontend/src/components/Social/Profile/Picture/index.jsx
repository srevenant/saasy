import React, { useRef, useState, useContext } from 'react'
import AvatarEditor from 'react-avatar-editor'
import Modal from 'tools/Modal'
import FileDialog from 'tools/File/Dialog'
import { uploadFile } from 'tools/File/upload'
import Store from 'store'
import style from './index.module.scss'
import config from 'constants/config'

const defaultState = {
  image: '',
  allowZoomOut: false,
  position: { x: 0.5, y: 0.5 },
  scale: 1,
  rotate: 0,
  borderRadius: 0,
  preview: null,
  width: 200,
  height: 200,
  loaded: false
}

function Picture({ image, refType, refId, type, children, onSuccess }) {
  const [edit, setEdit] = useState(false)
  const canEditPic = !!refId
  return (
    <>
      <div className="dib">
        <div
          className={`relative ${canEditPic ? 'pointer hover-hilight' : ''} br2`}
          onClick={() => canEditPic && setEdit(!edit)}
        >
          {children}
          {canEditPic && (
            <div className="absolute top-0 right-0">
              <i className="fas fa-edit gray" />
            </div>
          )}
        </div>
      </div>
      <Modal
        width="fw-50"
        viewState={[edit, setEdit]}
        className="theme-frame theme-bg-flat tc pa4"
      >
        <Editor
          image={image}
          refType={refType}
          refId={refId}
          type={type}
          onSuccess={(v) => {
            setEdit(false)
            onSuccess(v)
          }}
        />
      </Modal>
    </>
  )
}

function Editor({
  image,
  refType,
  refId,
  type,
  onSuccess,
  onFailure = () => {}
}) {
  const [{ apollo }] = useContext(Store)
  const editor = useRef()
  const [state, setStateInner] = useState({ ...defaultState, image: image.url })
  const setState = (keypair) => setStateInner({ ...state, ...keypair })
  const setFromEvent = (ev, key) =>
    setState({ [key]: parseFloat(ev.target.value) })
  const contentType = 'image/png'

  const saveFile = () => {
    // @ts-ignore
    const canvas = editor.current.getImageScaledToCanvas().toDataURL(contentType)
    fetch(canvas)
      .then((res) => res.blob())
      .then((blob) => {
        // if we set the file name it replaces things and caches get wierd
        // let's just delete old ones behind the scenes
        uploadFile({
          apollo,
          type,
          meta: { name: 'avatar', type: contentType, ref: refType },
          contentType: contentType,
          refId,
          src: blob,
          id: undefined,
          onSuccess,
          onFailure
        })
      })
  }

  // todo: add in uploading
  // https://www.npmjs.com/package/react-avatar-editor
  return (
    <div className="flex flex-column items-center">
      <div>
        <AvatarEditor
          ref={editor}
          scale={state.scale}
          width={state.width}
          height={state.height}
          position={state.position}
          onPositionChange={(position) => setState({ position })}
          rotate={state.rotate}
          image={state.image}
          className="editor-canvas"
        />
      </div>
      <div className="mt3 dib">
        <input
          type="range"
          step="0.01"
          min="0.5"
          max="2"
          name="scale"
          value={state.scale}
          disabled={!state.loaded}
          onChange={(ev) => setFromEvent(ev, 'scale')}
        />
      </div>
      <div className="flex justify-around mt3 w-100">
        <FileDialog
          idRef="upload-avatar"
          label="Choose File"
          onChange={(e) => setState({ image: e.target.files[0], loaded: true })}
          className="button border large"
        />
        <button className="large" onClick={saveFile} disabled={!state.loaded}>
          Save
        </button>
      </div>
    </div>
  )
}

export function EditViewer({
  origin,
  type,
  onSave,
  canEdit = true,
  round = true
}) {
  if (!origin._real) {
    return null
  }
  let avatar = origin.avatar.url
  if (!avatar && type === 'user') {
    const loc = parseInt('0x' + origin.id.slice(0, 8)) % 10
    avatar = `${config.imgurl}default/lego-${loc || 0}.jpg`
  }

  const view = (
    <div
      className={`${style.image} ${style.large} ${
        round ? style.round : ''
      } nomargin`}
    >
      <img src={avatar} alt="" />
    </div>
  )

  if (!canEdit) return view

  return (
    <Picture
      image={origin.avatar}
      type="avatar"
      onSuccess={onSave}
      refType={type}
      refId={origin.id}
    >
      {view}
    </Picture>
  )
}

export default EditViewer

export { style }
