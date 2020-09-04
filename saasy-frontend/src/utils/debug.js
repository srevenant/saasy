const DEBUG = true

export default function debug(arg1, arg2) {
  if (DEBUG) {
    console.log(`${Date.now()} ${arg1}`, arg2)
  }
}

export function nodebug() {}
