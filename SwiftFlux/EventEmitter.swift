public protocol EventEmitter {

    #if swift(>=3)
        func subscribe<T: Store>(_ store: T, handler: () -> ()) -> String
        func unsubscribe<T: Store>(_ store: T)
        func unsubscribe<T: Store>(_ store: T, listenerToken: StoreListenerToken)
        func emitChange<T: Store>(_ store: T)
    #else
        func subscribe<T: Store>(store: T, handler: () -> ()) -> String
        func unsubscribe<T: Store>(store: T)
        func unsubscribe<T: Store>(store: T, listenerToken: StoreListenerToken)
        func emitChange<T: Store>(store: T)
    #endif

}
