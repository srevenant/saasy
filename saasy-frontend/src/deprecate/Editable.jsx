// original source
// https://medium.com/@vraa/inline-edit-using-higher-order-components-in-react-7828687c120c
import React from 'react'

export default function Editable(WrappedComponent) {
  return class extends React.Component {
    state = {
      editing: false,
      lastClick: 0
    }

    toggleEdit = (ev) => {
      ev.stopPropagation()
      if (this.state.editing) {
        this.cancel()
      } else {
        this.edit({})
      }
    }

    edit = (moreState) => {
      this.setState(
        {
          ...moreState,
          editing: true
        },
        () => {
          if (this.props.realvalue) {
            this.domElm.textContent = this.props.realvalue
          }
          this.domElm.focus()
        }
      )
    }

    save = () => {
      this.setState(
        {
          editing: false
        },
        () => {
          if (this.isValueChanged()) {
            if (this.props.xsave) {
              this.props.xsave(this.domElm, this)
            }
          }
        }
      )
    }

    cancel = () => {
      this.setState({
        editing: false
      })
    }

    editOnClick = (ev) => {
      ev.stopPropagation()
      const now = Date.now()
      if (now - this.state.lastClick < 500) {
        this.edit({
          lastClick: now
        })
      } else {
        this.setState({
          lastClick: now
        })
      }
    }

    isValueChanged = () => {
      return this.props.children !== this.domElm.textContent
    }

    handleKeyDown = (e) => {
      const { key } = e
      switch (
        key // eslint-disable-line
      ) {
        case 'Enter':
        case 'Escape':
          this.save()
          break
        default:
      }
    }

    render() {
      const { editing } = this.state
      let { className } = this.props
      if (!className) {
        className = ''
      }
      return (
        <WrappedComponent
          className={`${className} ${editing ? 'editing' : ''}`}
          onClick={this.editOnClick}
          contentEditable={editing}
          ref={(node) => {
            this.domElm = node
          }}
          onBlur={this.save}
          onKeyDown={this.handleKeyDown}
          realvalue={this.props.realvalue}
        >
          {this.props.children}
        </WrappedComponent>
      )
    }
  }
}
