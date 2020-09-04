import React, { Component } from 'react'

class Menu extends Component {
  constructor(props) {
    super(props)

    this.state = {
      showMenu: false
    }

    this.showMenu = this.showMenu.bind(this)
    this.closeMenu = this.closeMenu.bind(this)
  }

  componentWillUnmount() {
    document.removeEventListener('click', this.closeMenu)
  }

  showMenu(event) {
    event.preventDefault()

    this.setState({ showMenu: true }, () => {
      document.addEventListener('click', this.closeMenu)
    })
  }

  closeMenu(event) {
    if (!this.dropdownMenu.contains(event.target)) {
      this.setState({ showMenu: false }, () => {
        document.removeEventListener('click', this.closeMenu)
      })
    }
  }

  render() {
    const s_top = this.props.styles.menuTop || 'menu'
    const s_title = this.props.styles.menuTitle || 'menu-title'
    const s_items = this.props.styles.menuItems || 'menu-items'
    const s_item = this.props.styles.menuItem || 'menu-item'
    return (
      <div className={s_top}>
        <div
          onClick={this.showMenu}
          className={`${this.props.classes} ${s_title}`}
        >
          {this.props.title}
        </div>
        {this.state.showMenu ? (
          <div className={s_items}>
            <div
              className={s_item}
              ref={(element) => {
                this.dropdownMenu = element
              }}
            >
              {this.props.children}
            </div>
          </div>
        ) : null}
      </div>
    )
  }
}

export default Menu
