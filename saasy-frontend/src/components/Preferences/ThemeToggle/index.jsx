import React, { useState, useEffect } from 'react'
import Toggle from 'tools/Toggle'

function ThemeToggle({ settings, makeChange, className = '', children = '' }) {
  const [light, setLight] = useState(false)

  useEffect(() => {
    setLight(settings.theme === 'light')
  }, [settings.theme])

  return (
    <>
      <div className={className}>
        <label className="f6 b db mb2 mt3 heading">Site Style</label>
      </div>
      {children}
      <div className="mv2 flex items-center pl2">
        <Toggle
          onChange={() => {
            const value = !light
            setLight(value)
            settings.theme = value ? 'light' : 'dark'
            makeChange({ settings: JSON.stringify(settings) })
          }}
          value={light}
        >
          Enable Light Mode
        </Toggle>
      </div>
    </>
  )
}

export default ThemeToggle
