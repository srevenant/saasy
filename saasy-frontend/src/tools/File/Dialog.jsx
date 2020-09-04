import React from 'react'
import style from './Dialog.module.scss'

function FileDialog({ idRef, className = '', label = 'Select File', onChange }) {
  return (
    <div className={style.uploader}>
      <label htmlFor={idRef} className={className}>
        {label}
      </label>
      <input id={idRef} type="file" onChange={onChange} />
    </div>
  )
}

export default FileDialog
