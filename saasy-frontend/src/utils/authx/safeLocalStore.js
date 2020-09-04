import { Base64 } from 'js-base64'
import nacl from 'tweetnacl' // cryptographic functions
import util from 'tweetnacl-util' // encoding & decoding
// import { authDebug } from './index'
const authDebug = (x, y, z) => {}

export const PUBKEY = 'LkgFIzUhudr3xtY1UK0zZaSoD89KhAra9a+4BS/QE3A='
export const PRVKEY = 'kByhcUytynXFAsjKZVfhfu1NAyc307SdcY4VhwsDhJs='

////////////////////////////////////////////////////////////////////////////////
function encrypt(receiverPublicKey, msgParams) {
  authDebug(4, '[authx/safeLocalStore].encrypt', '()')
  const ephemeralKeyPair = nacl.box.keyPair()
  const pubKeyUInt8Array = util.decodeBase64(receiverPublicKey)
  const msgParamsUInt8Array = util.decodeUTF8(msgParams)
  const nonce = nacl.randomBytes(nacl.box.nonceLength)
  const encryptedMessage = nacl.box(
    msgParamsUInt8Array,
    nonce,
    pubKeyUInt8Array,
    ephemeralKeyPair.secretKey
  )
  return {
    ciphertext: util.encodeBase64(encryptedMessage),
    ephemPubKey: util.encodeBase64(ephemeralKeyPair.publicKey),
    nonce: util.encodeBase64(nonce),
    version: 'x25519-xsalsa20-poly1305'
  }
}

////////////////////////////////////////////////////////////////////////////////
// Decrypt a message with a base64 encoded secretKey (privateKey)
function decrypt(receiverSecretKey, encryptedData) {
  authDebug(4, '[authx/safeLocalStore].decrypt', '()')
  const receiverSecretKeyUint8Array = util.decodeBase64(receiverSecretKey)
  const nonce = util.decodeBase64(encryptedData.nonce)
  const ciphertext = util.decodeBase64(encryptedData.ciphertext)
  const ephemPubKey = util.decodeBase64(encryptedData.ephemPubKey)
  const decryptedMessage = nacl.box.open(
    ciphertext,
    nonce,
    ephemPubKey,
    receiverSecretKeyUint8Array
  )
  // @ts-ignore
  return util.encodeUTF8(decryptedMessage)
}

////////////////////////////////////////////////////////////////////////////////
export function safeStoreDrop(key) {
  authDebug(4, '[authx/safeLocalStore] safeStoreDrop key=', key)
  localStorage.removeItem(key)
}

export function safeStorePut(key, data) {
  authDebug(4, '[authx/safeLocalStore] safeStorePut key=', key)
  const raw = encrypt(PUBKEY, JSON.stringify(data))
  const vers = 'v' // any single character as a version ID
  const encoded =
    vers +
    Base64.encode(
      `${raw.nonce}:${raw.version}:${raw.ciphertext}:${raw.ephemPubKey}`
    )
  localStorage.setItem(key, encoded)
  return encoded
}

export function safeStoreGet(key) {
  authDebug(4, '[authx/safeLocalStore] safeStoreGet key=', key)
  const data = localStorage.getItem(key)
  try {
    const vers = data.slice(0, 1)
    const decoded = Base64.decode(data.slice(1)).split(':')
    switch (
      vers // future proof schemes
    ) {
      case 'v':
        const raw = {
          nonce: decoded[0],
          version: decoded[1],
          ciphertext: decoded[2],
          ephemPubKey: decoded[3]
        }
        return JSON.parse(decrypt(PRVKEY, raw))
      default:
        return undefined
    }
  } catch (err) {
    return undefined
  }
}
