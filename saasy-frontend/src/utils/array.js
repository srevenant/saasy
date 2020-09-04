// using lists for ordered sets
export function setAdd(list1, component) {
  if (!list1.includes(component)) {
    list1.push(component)
  }
  return list1
}

export function setMerge(list1, list2) {
  list2.forEach((elem) => setAdd(list1, elem))
  return list1
}
