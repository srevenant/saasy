// import ReactGA from 'react-ga'
// import config from '../constants/config'

// note: the commented console.log is useful for development and debugging,
// so please leave in this file (BJG)

// ReactGA.initialize('UA-159302535-1')

// const PREFIX = config.lane + ':'

// might be better as a promises
export default {
  action: (path, callback) => {
    // console.log('GA-LOG', path)
    // ReactGA.pageview(path)
    if (callback) {
      callback()
    }
  },

  // event structure for us:
  // - category - the object/module interacted with
  // - action - the type of interaction
  // - label - (optional) - help sub-categorize
  // - value - (optional) - a numeric value for the event
  event: (ev, callback) => {
    // let { category } = ev
    // const event = { ...ev, category: PREFIX + category }
    // console.log('GA-LOG', event)
    // ReactGA.event(event)
    if (callback) {
      callback()
    }
  }
}
