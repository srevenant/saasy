import gql from 'graphql-tag'

export const fileVars = `
  id
  type
  path
  valid
  meta
  updatedAt
`
export const UPSERT_FILE = gql`
  mutation upsertUploadFile($file: InputUploadFile!) {
    upsertUploadFile(file: $file) {
      ${fileVars}
      signedUrl
    }
  }
`

export const DELETE_FILE = gql`
  mutation deleteUploadFile($file: InputUploadFile!) {
    deleteUploadFile(file: $file) {
      id
    }
  }
`
