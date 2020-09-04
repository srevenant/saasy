# How to use:

Setup <NotifyProvider></NotifyProvider> at the top level

    import { NotifyStore, notify } from '../../Notify/resolver'

in component:

    const [nStore, nDispatch] = useContext(NotifyStore)

in event that requires a notification, call:

    notify(nDispatch, <>message here</>)
