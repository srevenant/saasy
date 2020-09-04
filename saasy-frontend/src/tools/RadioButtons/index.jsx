import React from 'react'
import { capitalize } from 'utils/string'
import style from './index.module.scss'

export function genSaveRadio(onSave) {
  return ({ orig, type, token, boolTrue }, selected) => {
    let value
    switch (type) {
      case 'multiple':
        if (orig.includes(selected)) value = orig.filter((i) => i !== selected)
        else value = orig.concat(selected)
        break

      case 'boolean':
        value = selected === boolTrue
        break

      default:
        value = selected
    }

    onSave({ token, orig }, value)
  }
}

function RadioButtons({
  value,
  opts,
  onSave,
  capitalize: doCaps = true,
  token = undefined,
  type = 'one',
  boolTrue = undefined,
  className = '',
  buttonClass = 'mb2',
  variant = 'buttons'
}) {
  const columnar = variant === 'column'
  return (
    <div
      className={`${
        variant === 'buttons' ? 'flex flex-wrap items-center' : style.cols
      } ${className}`}
    >
      {opts.map((but, x) => {
        let bvalue = columnar ? but.value : but
        let blabel = columnar ? but.label : but

        let isActive = false
        switch (type) {
          case 'boolean':
            isActive =
              (value && boolTrue === bvalue) || (!value && boolTrue !== bvalue)
            break
          case 'multiple':
            isActive = (value || []).includes(bvalue)
            break
          default:
            isActive = value === bvalue
            break
        }
        return (
          <div
            key={`radio-${x}`}
            className="flex items-start"
            onClick={() =>
              onSave({ orig: value, opts, boolTrue, token, type }, bvalue)
            }
          >
            <button
              className={`${style.rb} nowrap ${
                isActive ? style.active : 'plain border'
              } ${buttonClass}`}
            >
              {doCaps ? capitalize(blabel) : blabel}
            </button>
            {columnar ? <i className="fw2 pt1"> &mdash; {but.text}</i> : null}
          </div>
        )
      })}
    </div>
  )
}

export default RadioButtons
