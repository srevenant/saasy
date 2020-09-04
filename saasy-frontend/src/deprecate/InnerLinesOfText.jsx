import React from 'react'

////////////////////////////////////////////////////////////////////////////////
// breakout so we can create a row identifier
function InnerLinesOfText({ text }) {
  let row = 0
  return text.map((item) => {
    if (!item || item.length === 0) {
      return null
    } else if (!item) {
      console.log('Inner with invalid data')
      return null
    } else {
      return item.split(/[\n\r]+/).map((line) => {
        row++
        if (line.length > 0) {
          return (
            <div
              key={row}
              className="ph2 pv1"
              style={{
                backgroundColor: 'var(--t-transbg-overlay-lesser)',
                margin: '2px'
              }}
            >
              {line}
            </div>
          )
        } else {
          return null
        }
      })
    }
  })
}
export default InnerLinesOfText
