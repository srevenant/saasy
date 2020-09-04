function shortId(long, len) {
  return long.replace('-', '').slice(0, len).toLowerCase()
}

export function minIds(list, idElem) {
  let len = 2
  const as_e = list.reduce((acc, elem) => {
    let subid
    while (!subid && len < 48) {
      subid = shortId(elem[idElem], len)
      if (subid in acc) {
        len++
        // eslint-disable-next-line
        acc = Object.keys(acc).reduce((acc2, key) => {
          acc2[shortId(acc[key][idElem], len)] = acc[key]
          return acc2
        }, {})
        subid = undefined
      } else {
        acc[subid] = elem
      }
    }
    return acc
  }, {})
  const as_m = Object.keys(as_e).reduce((acc, key) => {
    acc[as_e[key][idElem]] = key
    return acc
  }, {})
  return [as_m, as_e]
}

export default minIds
