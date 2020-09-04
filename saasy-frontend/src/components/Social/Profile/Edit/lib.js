import { SET_USER } from 'store'
import { ACTIONS } from '../resolver'
import { CHG } from 'tools/InputInline'

////////////////////////////////////////////////////////////////////////////////
export function nestedVars(person, type, tok, value) {
  const cur = person.dataTypes[type] || {}
  if (cur.value[tok] === value) {
    return { changes: false, vars: undefined }
  }
  let updated = { ...(cur.value || {}), [tok]: value }
  // our search checks for value is null to determine something is off,
  // so delete it instead of setting it to false
  if (value === false) {
    delete updated[tok]
  }
  return {
    changes: true,
    vars: {
      id: person.id,
      userData: {
        id: cur.id,
        userId: person.id,
        type: type,
        value: JSON.stringify(updated)
      }
    }
  }
}

////////////////////////////////////////////////////////////////////////////////
export function genSavePerson(person, mutate, { pDisp, gDisp, myId }) {
  // / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / /
  const commit = ({ changes, vars, good, bad }) => {
    if (!changes) {
      return good && good(CHG.OK)
    } else if (!vars) {
      return bad && bad('no args?')
    }
    mutate({
      variables: vars,
      update(
        cache,
        {
          data: {
            updatePerson: { success, reason, result }
          }
        }
      ) {
        if (success) {
          pDisp && pDisp({ type: ACTIONS.SET_PERSON, value: result })
          if (gDisp && myId === result.id) {
            gDisp({ type: SET_USER, value: result })
          }
          good && good(CHG.SAVED)
        } else {
          bad && bad(reason)
        }
      }
    })
  }

  // / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / / /
  return ({ tok, orig = undefined }, value, good, bad) => {
    let changes = true
    let vars = { id: person.id }
    let args = { changes, good, bad }
    switch (tok) {
      case 'street':
      case 'city':
      case 'state':
        return commit({ ...args, ...nestedVars(person, 'address', tok, value) })
      case 'handle':
      case 'settings':
      case 'name':
        if (orig === value) {
          return good(CHG.OK)
        }
        vars = { ...vars, [tok]: value }
        return commit({ ...args, vars })
      case 'phone':
        vars = {
          ...vars,
          phone: value
        }
        return commit({ ...args, vars })

      case 'desc':
      case 'interest':
        return commit({
          ...args,
          ...nestedVars(person, 'tags', tok, value)
        })

      case 'hide_name':
      case 'hide_city':
      case 'hide_state':
      case 'hide_desc':
      case 'contributor':
      case 'investor':
      case 'accredited':
      case 'provider':
      case 'proxy':
        return commit({ ...args, ...nestedVars(person, 'toggles', tok, value) })
      default:
        console.log(`Unrecognized onSave change token: ${tok}`)
        break
    }
  }
}
