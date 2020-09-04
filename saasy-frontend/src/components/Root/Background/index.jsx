import React, { useContext } from 'react'
import style from './index.module.scss'
import Store from 'store'

function Background() {
  const [
    {
      page: { image, background }
    }
  ] = useContext(Store)

  return (
    <div
      className={`${style.bg} theme-base-flat`}
      style={
        background !== 'flat'
          ? { backgroundImage: image ? `url('${image[1440]}')` : '' }
          : {}
      }
    >
      {background !== 'flat' ? (
        <div className={`${style.bg} theme-fade-layer5`} />
      ) : (
        ''
      )}
    </div>
  )
}

export default Background
