import React from 'react'
import Switch from 'react-switch'

export function Toggle({
  value = false,
  onChange = (v) => {},
  children = undefined
}) {
  return (
    <>
      <div
        className="mv2 flex items-center pl2 pointer hover-hilight br3"
        onClick={() => onChange(!value)}
      >
        <Switch
          onChange={() => {}}
          checked={value}
          onColor="#3696ff"
          offColor="#394247"
          height={12}
          width={30}
          className="mr2"
          activeBoxShadow="0 0 2px 3px white"
        />
        {children ? <div>{children}</div> : null}
      </div>
    </>
  )
}

export function ToggleDict({
  settings,
  onChange,
  children,
  keyword,
  subkey,
  invert
}) {
  let setdict = settings
  if (subkey) {
    if (!settings[subkey]) {
      settings[subkey] = {}
    }
    setdict = settings[subkey]
  }

  // invert so it's on by default, even if not set
  const value = invert ? setdict[keyword] : !setdict[keyword]

  return (
    <Toggle
      value={value}
      onChange={(a) => {
        console.log('<TOGGLE Dict>', a)
        const val = !value
        if (invert ? val : !val) {
          setdict[keyword] = true
        } else {
          delete setdict[keyword]
        }
        onChange(setdict)
      }}
    >
      {children}
    </Toggle>
  )
}

export default Toggle
