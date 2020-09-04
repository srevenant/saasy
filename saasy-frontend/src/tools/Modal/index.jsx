import React from 'react'
import style from './index.module.scss'
import Modal from 'react-modal'
import Scrollbar from 'tools/Scrollbar'

function MyModal({
  width,
  viewState: [modalOpen, setModalOpen],
  header = undefined,
  children = undefined,
  noScroll = false,
  className = ''
}) {
  // TODO: in the future address ariaHideApp
  // warn msg:
  //    Warning: react-modal: App element is not defined. Please use `Modal.setAppElement(el)` or set `appElement={el}`. This is needed so screen readers don't see main content when modal is opened. It is not recommended, but you can opt-out by setting `ariaHideApp={false}`.

  if (modalOpen) {
    return (
      <Modal
        isOpen={!!modalOpen}
        ariaHideApp={false}
        onRequestClose={() => setModalOpen(false)}
        className={style.modal}
        overlayClassName={style.overlay}
      >
        <div
          className={`${style.frame} ${width ? style[width] : style['fw-50']}
          theme-frame theme-bg-flat ${style.modal}`}
        >
          {header ? (
            <div
              className={`theme-bg-alt b ph2 pa1 w-100`}
              style={{ borderTopLeftRadius: '0.5rem' }}
            >
              {header}
            </div>
          ) : null}
          <div
            className={`${style.close} pa1 flex-center br2`}
            onClick={() => setModalOpen(false)}
          >
            <i className="fas fa-times b" />
          </div>
          <div className={`${className ? className : style.body} w-100`}>
            {noScroll ? (
              children
            ) : (
              <Scrollbar className="scroll2h">{children}</Scrollbar>
            )}
          </div>
        </div>
      </Modal>
    )
  } else {
    return null
  }
}

export default MyModal
