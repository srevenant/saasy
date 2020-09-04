import gql from 'graphql-tag'

const publicValues = `
  id
  handle
  name
  verified
  lastSeen
  tags {
    id
    type
    tag {
      id
      label
      meta
    }
  }
  data {
    id
    type
    value
  }
  avatar
  updatedAt
  insertedAt
`

const personValues = `
  ${publicValues}
  emails {id,address,primary,verified}
  phones {id,number,primary,verified}
  settings
  access { roles, actions }
  authStatus
`

export const READ_SELF = gql`
{
  self {
    ${personValues}
    journey_actor {
      id
    }
  }
}
`

export const PUBLIC_PERSON = gql`
  query publicPerson($target: String!) {
    publicPerson(target: $target) {
      success
      reason
      result {
        ${publicValues}
      }
    }
  }
`

export const FULL_PUBLIC_PERSON = gql`
  query publicPerson($target: String, $id: String) {
    publicPerson(target: $target, id: $id) {
      success
      reason
      result {
        ${publicValues}
        projects {
          id
          project {
            id
            shortId
            title
            status
            stage
            subtitle
            updatedAt
            insertedAt
            avatar
          }
        }
        journey_actor {
          id
        }
      }
    }
  }
`

export const UPDATE_PERSON = gql`
mutation updatePerson(
    $id: String!,
    $name: String, $settings: String, $handle: String,
    $phone: String, $rmphone: String,
    $email: String, $rmemail: String, $verifyemail: String,
    $userData: InputUserData)
  {
    updatePerson(
      id: $id,
      name: $name, settings: $settings, handle: $handle,
      phone: $phone, rmphone: $rmphone,
      email: $email, rmemail: $rmemail, verifyemail: $verifyemail,
      userData: $userData)
    {
      success
      reason
      result {
        ${personValues}
      }
    }
  }
`

export const LIST_PUBLIC_PEOPLE = gql`
query publicPeople($filter: PeopleFilter!) {
  publicPeople(filter: $filter) {
    success
    reason
    total
    result {
      ${publicValues}
    }
  }
}
`

export const LIST_PEOPLE = gql`
query people($filter: PeopleFilter!) {
  people(filter: $filter) {
    success
    reason
    total
    results {
      ${personValues}
      last_seen
    }
  }
}
`

export const GEN_APIKEY = gql`
  mutation genApiKey {
    genApiKey {
      access
      validation
    }
  }
`

export const GET_INVITES = gql`
  mutation getInvites {
    getInvites {
      codes
    }
  }
`

export const REQUEST_PASSWORD_RESET = gql`
  mutation requestPasswordReset($email: String!) {
    requestPasswordReset(email: $email) {
      success
    }
  }
`

export const CHANGE_PASSWORD = gql`
  mutation changePassword($current: String, $new: String!, $email: String) {
    changePassword(current: $current, new: $new, email: $email) {
      success
      reason
    }
  }
`

export const MY_FACTORS = gql`
  query myFactors($type: String) {
    self {
      id
      factors(type: $type) {
        id
        type
        expiresAt
      }
    }
  }
`
