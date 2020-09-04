import React from 'react'

/* istyle = import/merge styles of groups. All of a group will take priority
 * do this by defining as grp<style1 style2 style3>
 */

/*
 * take in prefix<values> and expand to dictionary, and keep track of position
 *
 *  > iStyleExpand("p<pa1 pa2-ns> pa1 f<fa1 fa2-ns> z<za> fw1")
 *  [{ p: 'pa1 pa2-ns', f: 'fa1 fa2-ns', z: 'za' }, 'p{} pa1 f{} z{} fw1']
 *
 */
//const debug = console.log
//const debug = () => {}

function iStyleExpandWith(str) {
  if (!str) {
    return [{}, '']
  }
  let exp = {}
  let istyle_rx = /([a-z-]+)<([^>]*)>/
  let match
  while ((match = istyle_rx.exec(str))) {
    // eslint-disable-line
    const type = match[1]
    let vals = match[2].split(/\s+/)
    if (vals.length === 1 && vals[0] === '') {
      exp[type] = []
    } else {
      exp[type] = vals
    }
    str = str.replace(istyle_rx, `${type}{}`)
  }
  let opts = str.split(/\s+/)
  if (opts.length === 1 && opts[0] === '') {
    opts = []
  }
  //debug("explodify=>", exp, opts)
  return [exp, opts]
}

/*
 * specify styles (default + asked), only adding extra info from `want`
 * (i.e. anything outside of the import style string is ignored)
 *
 *  > istyle("pre p<pa1 pa2-ns> mid f<fa1 fa2-ns> z<za> after", "p<pa3> mo f<> bo")
 *
 *
 */
function lremove(list, item) {
  const x = list.indexOf(item)
  if (x !== -1) {
    // wtf list.slice(x, x+1) behaves differently
    return [...list.slice(0, x), ...list.slice(x + 1)]
  }
}
// replace an element in a list but by merging in another list
// creates a new list (immutable/functional, returns a new list)
function lreplaceMerge(first, index, insert) {
  /*
  if (!Array.isArray(first)) {
    throw("First arg is not an array")
  }
  if (!Array.isArray(insert)) {
    throw("Second arg is not an array")
  }
  */
  if (index === 0) {
    let x = [...insert, ...first.slice(1)]
    return x
  } else if (index === first.length) {
    let x = [...first.slice(0, -1), ...insert]
    return x
  } else {
    let end = first.slice(index + 1)
    let begin = first.slice(0, index)
    let x = [...begin, ...insert, ...end]
    return x
  }
}
function lreplace(list, item, insert) {
  /*
  if (typeof(insert) === String) {
    insert = [insert]
  }
  if (!Array.isArray(list) || !Array.isArray(insert)) {
    raise("barf")
  }
  */
  let x = list.indexOf(item)
  while (x > -1) {
    list = lreplaceMerge(list, x, insert)
    x = list.indexOf(item)
  }
  return list
}

export function istyle(def, want) {
  let [dexp, dstr] = iStyleExpandWith(def)
  let [wexp, wstr] = iStyleExpandWith(want)
  const merged = Object.assign({}, dexp, wexp)
  let remain = Object.assign({}, merged)

  // for all keys
  for (let key in merged) {
    const repl = `${key}{}`
    const def_opts = dexp[key] || []
    const want_opts = wexp[key] || []
    //debug("KEY=", wstr, repl)

    // if wants - check for regex's, so do each want option individually
    if (wstr.includes(repl)) {
      let new_opts = [...def_opts] // start with the default
      let new_want = []
      //debug("len=", repl, want_opts.length, want_opts)
      if (want_opts.length > 0) {
        for (let o in want_opts) {
          let opt = want_opts[o]
          //debug("sliced", opt.slice(0, 1))
          if (opt.slice(0, 1) === '!') {
            let rex = opt.slice(1)
            if (!rex) {
              // ! and no rex is delete all
              new_opts = []
            } else {
              rex = RegExp(rex)
              let new2 = []
              for (let e in new_opts) {
                let elem = new_opts[e]
                if (!elem.match(rex)) {
                  new2.push(elem)
                }
              }
              new_opts = new2
            }
          } else {
            new_want.push(opt)
          }
        }
      }
      // append what we want
      new_opts = [...new_opts, ...new_want]
      //debug("WANT", wstr, repl, new_opts)
      wstr = lreplace(wstr, repl, new_opts)
      if (dstr.includes(repl)) {
        dstr = lremove(dstr, repl)
      }
      delete remain[key]

      // only in defaults
    } else if (dstr.includes(repl)) {
      //debug("DEFAULT", repl, def_opts, def_opts)
      dstr = lreplace(dstr, repl, def_opts)
      delete remain[key]
    }
  }

  // what's left over
  for (let key in remain) {
    dstr.push(remain[key])
  }
  let set = new Set([...dstr, ...wstr])
  set.delete('')
  return Array.from(set).join(' ')
}
/*
let tests = [
  [["pre p<pa1 pa2-ns> d<> mid f<fa1 fa2-ns> z<za> after",
    "p<pa3> mo f<!> bo"],
   "pre mid za after pa1 pa2-ns pa3 mo bo"],
  [["pre p<pa1 pa2-ns> d<> mid f<fa1 fa2-ns> z<za> after",
    "p<pa3> mo f<hi> bo"],
   "pre mid za after pa1 pa2-ns pa3 mo fa1 fa2-ns hi bo"],
  [["pre p<pa1 pa2-ns> d<> mid f<fa1 fa2-ns> z<za> after",
    "p<!^pa1> mo f<> bo"],
   "pre mid za after pa2-ns mo fa1 fa2-ns bo"],
  [["pre p<pa1 pa2-ns> d<> mid f<fa1 fa2-ns> z<za> after",
    "p<!^pa[0-9]> mo f<> bo"],
   "pre mid za after mo fa1 fa2-ns bo"],
  [["pre p<pa1 pa2-ns bob> d<> mid f<fa1 fa2-ns> z<za> after",
    "p<!^pa[0-9]> mo f<> bo"],
   "pre mid za after bob mo fa1 fa2-ns bo"],
  [["pre p<pa1 pa2-ns> d<> mid f<fa1 fa2-ns> z<za> after",
    "p<pa4-l> mo f<> bo"],
   "pre mid za after pa1 pa2-ns pa4-l mo fa1 fa2-ns bo"],
  // 6
  [["pre p<pr1 pb2 pb3 pa2-ns> d<> mid f<fa1 fa2-ns> z<za> after",
    "p<!^pr ns> mo bo"],
   "pre mid fa1 fa2-ns za after pb2 pb3 pa2-ns ns mo bo"],
  // 7
  [["pre p<pr1 pb2 pb3 pa2-ns> f<one> after",
    "p<!^pr !^pb3 ns> mo f<> bo"],
   "pre after pb2 pa2-ns ns mo one bo"],
  [[
    "w-50 br1 b--gray",
    "w-<!^w w-100> br<br2> ma<ma0> ba b-<!^b b--transparent>",
  ],
   "pre after pb2 pa2-ns ns mo one bo"],
]
for (let x in tests) {
  let test = tests[x]
  console.log("================", x, test[0])
  let result = istyle(...test[0])
  console.log("expected:", test[1])
  console.log("received:", result)
  if (result != test[1]) {
    console.log(x, "=> FAIL")
    proc.exit()
  } else {
    console.log(x, "=> OK")
  }
}
*/
/*

SYNAX:

    prefix<add>     - take all matching (^prefix) and do a set-add of 'add' bits
        pa<pa1-m pa2-l> against "pa0 ma1" becomes "pa0 pa1-m pa2-l ma1"

    prefix<!rx replace> - remove all matching rx and replace them with contents
    prefix<! replace> - remove all matching prefix and replace them with contents

*/

function IDiv(props) {
  const classes = istyle(props.default, props.classes)
  return <div className={classes} />
}
export default IDiv
