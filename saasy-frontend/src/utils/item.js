import { strcmp, intcmp } from './string'

////////////////////////////////////////////////////////////////////////////////
export function formattedName(item) {
  // NO-LABEL item.label
  return item.taxonomy.meta.name || item.taxonomy.key
  /*
  // after refactoring taxonomy, bring it in here to make the name nicer
  if (item.meta.stars) {
    if (item.meta.effects.short) {
      name +=
    }
  }
  */
}

export function itemFilter(item, [string]) {
  if (string.length === 0) {
    return true
  }
  if (!item._filter) {
    item._filter = {
      name: formattedName(item).toLowerCase(),
      notes: (item.meta.notes || '').toLowerCase(),
      effects: item.meta.effects
        ? item.meta.effects.abbr.toLowerCase() + ' ' + item.meta.effects.short
        : ''
    }
  }

  return (
    item._filter.name.includes(string) ||
    item._filter.notes.includes(string) ||
    item._filter.effects.includes(string)
  )
}

////////////////////////////////////////////////////////////////////////////////
export function getEstimate(item) {
  if (!item || !item.meta.estimate) {
    return ''
  }
  const estimate = item.meta.estimate
  if (estimate.mine && estimate.mine > 0) {
    return estimate.mine
  } else if (estimate.PC && estimate.PC > 0) {
    return estimate.PC
  } else if (estimate.SWAG && estimate.SWAG > 0) {
    return estimate.SWAG
  }
  return ''
}

////////////////////////////////////////////////////////////////////////////////

// function flattenFormat(fmtDict) {
//   fmtDict.combined = fmtDict.effects
//     .reduce((acc, i) => {
//       if (i.length > 0) {
//         acc.push(i)
//       }
//       return acc
//     }, [])
//     .join('/')
//   if (fmtDict.combined.length > 0) {
//     return fmtDict.combined + ' ' + fmtDict.item
//   }
//   return fmtDict.item
// }
//
export function generateFormat({
  taxonomy,
  itemState,
  effect1State,
  effect2State,
  effect3State
}) {
  const [item] = itemState
  const format = {
    stars: 0,
    factor: 1,
    taxonomyId: '',
    features: [],
    itemType: {},
    effectTypes: [{}, {}, {}],
    game: { primary: '', item: '', factor: 1 },
    simple: { effects: ['', '', ''], item: '', factor: 1 },
    short: { effects: ['', '', ''], item: '', combined: '', factor: 1 },
    explain: { effects: ['', '', ''] }
  }

  function setEffects(key, node) {
    if (node && node.meta) {
      // if (item) {
      //   let item2effect = format.itemType.type
      // }
      format.features.push(node.value)
      format.stars++
      if (key === 0) {
        format.game.primary = node.meta.name // NOLABEL: node.meta.label ? node.meta.label : node.meta.name
      }
      format.simple.effects[key] = node.value
      format.short.effects[key] = node.meta.lookup[0]
      format.explain.effects[key] = node.meta.explain
        ? node.meta.explain
        : node.meta.text
        ? node.meta.text
        : node.meta.name
    }
  }
  if (item) {
    format.taxonomyId = item.id
    format.itemType = taxonomy.tree[item.type][item.label]
    format.game.item = item.label
    format.simple.item = item.value
    format.short.item = item.value
  }

  setEffects(0, effect1State[0])
  setEffects(1, effect2State[0])
  setEffects(2, effect3State[0])

  function flattenFormat(fmtDict) {
    fmtDict.combined = fmtDict.effects
      .reduce((acc, i) => {
        if (i.length > 0) {
          acc.push(i)
        }
        return acc
      }, [])
      .join('/')
    if (fmtDict.combined.length > 0) {
      return fmtDict.combined + ' ' + fmtDict.item
    }
    return fmtDict.item
  }
  format.game.label = format.game.primary + ' ' + format.game.item
  format.short.label = flattenFormat(format.short)
  format.simple.label = flattenFormat(format.simple).toLowerCase()
  format.explain.info = format.explain.effects.reduce((acc, i) => {
    if (i.length > 0) {
      acc.push(i)
    }
    return acc
  }, [])

  return format
}

////////////////////////////////////////////////////////////////////////////////
export const ITEM_COLUMNS = ['Name', 'Effects', 'Notes', 'Cost', 'Level', 'QTY']
const ITEM_COL_DATA = {
  QTY: {
    sort: (a, b) => intcmp(a.meta.qty || 0, b.meta.qty || 0),
    align: 'right'
  },
  Name: {
    sort: (a, b) => strcmp(formattedName(a), formattedName(b)),
    align: 'left'
  },
  Level: {
    sort: (a, b) => intcmp(a.meta.level || 0, b.meta.level || 0),
    align: 'right'
  },
  Effects: {
    sort: (a, b) => {
      if (a.meta.effects && b.meta.effects) {
        return strcmp(a.meta.effects.abbr, b.meta.effects.abbr)
      }
      return 0
    },
    align: 'left'
  },
  Notes: { sort: (a, b) => strcmp(a.meta.notes, b.meta.notes), align: 'left' },
  Cost: { sort: (a, b) => 0, align: 'right' }
}

export function sortItems(items, { itemSort: { cols, reverse } }) {
  const c1sort = ITEM_COL_DATA[cols[0]].sort
  const c2sort = ITEM_COL_DATA[cols[1]].sort
  return items.sort((a, b) => c1sort(a, b) || c2sort(a, b) || strcmp(a.id, b.id))
}
