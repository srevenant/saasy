import axios from 'axios'
import { UPSERT_FILE } from 'constants/File'

export function uploadFile({
  apollo,
  type,
  contentType,
  meta,
  refId,
  id = undefined,
  src,
  onSuccess,
  onFailure = (e) => {},
  debug = false
}) {
  if (!meta.ref) {
    throw new Error('No .ref in meta')
  }
  return getFileHandle({ apollo, type, refId, id, debug, meta }).then(
    ({
      data: {
        upsertUploadFile: { id, signedUrl }
      }
    }) => {
      debug && console.log('upload:getFileHandle =>', id, signedUrl)
      // we have a handle to send to, now upload it...
      return pushFile({ src, dst: signedUrl, contentType, debug })
        .then((result) => {
          debug && console.log('upload:pushFile =>', result)
          // we have uploade the file, now mark it as valid on our backend
          return validFile({ apollo, type, id, debug }).then((result) => {
            debug && console.log('upload:validFile =>', result)
            return onSuccess(result.data.upsertUploadFile)
          })
        })
        .catch((error) => {
          debug && console.log('upload:onFailure =>', error)
          return onFailure(error)
        })
    }
  )
}

// some of these abstractions are just to make the readability above easier
function getFileHandle({ apollo, type, refId, id, meta, debug }) {
  debug && console.log(`upload:getFileHandle type=${type}, refId=${refId})`)
  return apollo.mutate({
    mutation: UPSERT_FILE,
    variables: {
      file: { id, type, refId, genUrl: true, meta: JSON.stringify(meta) }
    }
  })
}

function validFile({ apollo, type, id, debug }) {
  debug && console.log(`upload:validFile type=${type}, id=${id})`)
  return apollo.mutate({
    mutation: UPSERT_FILE,
    variables: { file: { id, type, valid: true } }
  })
}

function pushFile({ src, dst, contentType, debug }) {
  const options = {
    headers: {
      'Content-Type': contentType || 'application/octet-stream'
    }
  }

  debug && console.log('upload:pushFile src=', src, options)
  return axios.put(dst, src, options)
}
