import {
  verbs,
  adverbs,
  adjectives,
  nouns,
  sub_nouns
} from '../constants/loadingBabble'

function chance(percent) {
  if (Math.random() * 100 <= percent) {
    return true
  }
  return false
}
function random(array) {
  return array[Math.floor(Math.random() * array.length)]
}

export function loadingBabble() {
  let accum = [random(verbs), 'the']
  if (chance(25)) {
    accum.push(random(adverbs))
  }
  accum.push(random(adjectives))
  accum.push(random(nouns))
  if (chance(50)) {
    accum.push(random(sub_nouns))
  }
  const result = accum.join(' ')
  return result[0].toUpperCase() + result.slice(1)
}
