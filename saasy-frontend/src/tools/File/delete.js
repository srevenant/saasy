import { DELETE_FILE } from 'constants/File'

export function deleteFile({
  apollo,
  file,
  debug = false,
  onSuccess,
  onFailure = (e) => {}
}) {
  return apollo
    .mutate({
      mutation: DELETE_FILE,
      variables: { file: file }
    })
    .then((result) => {
      debug && console.log('delete:then =>', result)
      return onSuccess(result.data.deleteUploadFile)
    })
    .catch((error) => {
      debug && console.log('delete:catch =>', error)
      return onFailure(error)
    })
}
