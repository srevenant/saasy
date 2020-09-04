import React, { useState, useEffect } from 'react'
import NumberFormat from 'react-number-format'
export const inputClasses = '' // ba b--gray br2 pa2'

export const CHG = {
  OK: 0,
  DIRTY: 1,
  SAVED: 2
}

////////////////////////////////////////////////////////////////////////////////
// this will go away after I spend a few mins and get Profile/Settings migrated
export function InputInlineSolo({
  value,
  onSave,
  label = '',
  placeholder = '',
  numberFormatter = false,
  prefix = '',
  suffix = '',
  format = '',
  icons = true,
  inputClass = 'w-100',
  wrapClass = '',
  className = '',
  ...rest
}) {
  const classes = `${inputClasses} ${inputClass}`
  const { disabled } = rest
  const [dirty, setDirty] = useState(CHG.OK)
  const [val, setVal] = useState(value)
  const save = (value) =>
    new Promise((resolve) => {
      onSave(value)
      resolve(value)
    }).then(() => {
      setDirty(CHG.SAVED)
    })

  return (
    <div className={className}>
      {label ? (
        <div className="mv2">
          <label>{label}</label>
        </div>
      ) : null}
      <div className={`flex items-center ${wrapClass}`}>
        {numberFormatter ? (
          <NumberFormat
            suffix={suffix}
            prefix={prefix}
            format={format || null}
            value={val || ''}
            disabled={disabled}
            onChange={(ev) => {
              setVal(ev.target.value)
              setDirty(CHG.DIRTY)
            }}
            onKeyDown={(ev) => {
              if (ev.key === 'Enter') {
                save(val)
              }
            }}
            onBlur={(e) => {
              save(val)
            }}
            type="text"
            placeholder={placeholder}
            className={classes}
          />
        ) : (
          <input
            value={val || ''}
            disabled={disabled}
            onChange={(ev) => {
              setVal(ev.target.value)
              setDirty(CHG.DIRTY)
            }}
            onKeyDown={(ev) => {
              if (ev.key === 'Enter') {
                save(val)
              }
            }}
            onBlur={(e) => {
              save(val)
            }}
            type="text"
            placeholder={placeholder}
            className={classes}
          />
        )}
        {icons ? <DirtyIcon dirty={dirty} /> : null}
      </div>
    </div>
  )
}

////////////////////////////////////////////////////////////////////////////////
function deferSave(arg, value, good, bad, error) {
  good()
}

export function InputInline({
  valState: [val, setVal],
  onSave = deferSave,
  ...optional
}) {
  const {
    help,
    label,
    icons = true,
    numberFormatter = false,
    validate,
    // isDirty = false,
    selected,
    autoWidth = 0,
    minmax = [3, 15],
    inputClass = 'w-100',
    wrapClass = '',
    className = '',
    ...args
  } = optional
  const classes = `${inputClasses} ${inputClass}`
  const [dirty, setDirty] = useState(CHG.OK)
  const [orig, setOrig] = useState(val)
  const [mesg, setMesg] = useState(<></>)
  const error = (errmsg) => setMesg(<div className="pv2 f7 red">{errmsg}</div>)

  useEffect(() => {
    let isMounted = true
    if (dirty === CHG.SAVED) {
      setTimeout(() => {
        if (isMounted) {
          setDirty(CHG.OK)
          setMesg(null)
        }
      }, 3000)
    }
    return () => (isMounted = false)
  }, [dirty])

  const save = (value) => {
    return new Promise((resolve, reject) => {
      return onSave({ ...optional, orig }, value, resolve, reject, error)
    })
      .then((wat = CHG.SAVED) => {
        setMesg(<></>)
        setDirty(wat)
        setOrig(value)
      })
      .catch((errmsg) => {
        error(errmsg)
        setDirty(CHG.DIRTY)
      })
  }

  const onChange = (ev) => {
    let val = ev.target.value
    if (validate) {
      const { value, error } = validate(val)
      if (error) {
        error(error)
        return
      }
      val = value
    }
    setVal(val)
    setDirty(CHG.DIRTY)
  }
  args.className = classes
  args.onBlur = (e) => save(val)
  args.onKeyDown = (ev) => {
    if (ev.key === 'Enter') save(val)
  }
  args.value = val
  args.onChange = onChange
  args.onFocus = (e) => (selected ? e.target.select() : null)
  if (autoWidth) {
    let width = (`${val}`.length + 1) * autoWidth
    if (width < minmax[0]) {
      width = minmax[0]
    } else if (width > minmax[1]) {
      width = minmax[1]
    }
    args.style = { width: `${width}rem` }
  }

  return (
    <div className={`input-inline ${className}`}>
      {label ? (
        <div className="mv2">
          <label>{label}</label>
        </div>
      ) : null}
      {help ? <div className="f6 mb2 gray">{help}</div> : null}
      <div className={`flex items-center ${wrapClass}`}>
        {numberFormatter ? <NumberFormat {...args} /> : <input {...args} />}
        {icons ? <DirtyIcon dirty={dirty} /> : null}
      </div>
      {mesg}
    </div>
  )
}

export function Textarea({
  valState: [val, setVal],
  onSave = deferSave,
  ...optional
}) {
  const {
    icons = true,
    disabled,
    help,
    label,
    placeholder,
    validate,
    selected,
    inputClass,
    minRows = 3,
    className = '',
    wrapClass = '',
    rows,
    ...rest
  } = optional
  let inClass = inputClass
  if (!inClass) {
    inClass = 'w-100'
  }
  const [dirty, setDirty] = useState(CHG.OK)
  const [mesg, setMesg] = useState(<></>)
  const error = (errmsg) => setMesg(<div className="pb2 f7 red">{errmsg}</div>)

  useEffect(() => {
    let isMounted = true
    if (dirty === CHG.SAVED) {
      setTimeout(() => {
        if (isMounted) {
          setDirty(CHG.OK)
          setMesg(null)
        }
      }, 3000)
    }
    return () => (isMounted = false)
  }, [dirty])

  const save = (value) => {
    return new Promise((resolve, reject) =>
      onSave(optional, value, resolve, reject)
    )
      .then(() => {
        setMesg(<></>)
        setDirty(CHG.SAVED)
      })
      .catch((errmsg) => {
        error(errmsg)
        setDirty(CHG.DIRTY)
      })
  }
  if (rows) {
    rest.rows = rows
  } else {
    rest.rows =
      val
        .split(/\n/)
        .reduce((acc, line) => acc.concat(line.match(/.{1,80}/g)), []).length + 1
    if (rest.rows > 25) {
      rest.rows = 25
    }
    if (rest.rows < minRows) {
      rest.rows = minRows
    }
  }

  return (
    <div className={`input-inline ${className}`}>
      {label ? (
        <div className="mv2">
          <label>{label}</label>
        </div>
      ) : null}
      {help ? <div className="f6 mb2 gray">{help}</div> : null}
      <div className={`flex items-center ${wrapClass}`}>
        <textarea
          value={val || ''}
          disabled={disabled}
          onChange={(ev) => {
            let val = ev.target.value
            if (validate) {
              const { value, error } = validate(val)
              if (error) {
                error(error)
                return
              }
              val = value
            }
            setVal(val)
            setDirty(CHG.DIRTY)
          }}
          onFocus={(e) => (selected ? e.target.select() : null)}
          onBlur={(e) => {
            save(val)
          }}
          placeholder={placeholder}
          className={`${inputClasses} ${inClass}`}
          {...rest}
        />
        {icons ? <DirtyIcon dirty={dirty} /> : null}
      </div>
      {mesg}
    </div>
  )
}

////////////////////////////////////////////////////////////////////////////////
function DirtyIcon({ dirty }) {
  if (dirty === CHG.DIRTY) return <i className="fas fa-save red ml2" />
  if (dirty === CHG.SAVED) return <i className="fas fa-check green ml2" />
  return null
  // return <i className="fas fa-save ml2" style={{ color: 'transparent' }} />
}

export default InputInline
