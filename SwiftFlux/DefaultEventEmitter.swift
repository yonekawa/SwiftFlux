public class DefaultEventEmitter: EventEmitter {

    private var eventListeners: [StoreListenerToken: EventListener] = [:]

    public init() {}

    deinit {
        eventListeners.removeAll()
    }

    #if swift(>=3)
        public func subscribe<T: Store>(_ store: T, handler: () -> ()) -> StoreListenerToken {
            let nextListenerToken = uuidString()
            eventListeners[nextListenerToken] = EventListener(store: store, handler: handler)
            return nextListenerToken
        }
    #else
        public func subscribe<T: Store>(store: T, handler: () -> ()) -> StoreListenerToken {
            let nextListenerToken = uuidString()
            eventListeners[nextListenerToken] = EventListener(store: store, handler: handler)
            return nextListenerToken
        }
    #endif

    #if swift(>=3)
        public func unsubscribe<T: Store>(_ store: T) {
            eventListeners.forEach { (token, listener) -> () in
                if (listener.store === store) {
                    eventListeners.removeValue(forKey: token)
                }
            }
        }
    #else
        public func unsubscribe<T: Store>(store: T) {
            eventListeners.forEach { (token, listener) -> () in
                if (listener.store === store) {
                    eventListeners.removeValueForKey(token)
                }
            }
        }
    #endif

    #if swift(>=3)
        public func unsubscribe<T: Store>(_ store: T, listenerToken: StoreListenerToken) {
            eventListeners.removeValue(forKey: listenerToken)
        }
    #else
        public func unsubscribe<T: Store>(store: T, listenerToken: StoreListenerToken) {
            eventListeners.removeValueForKey(listenerToken)
        }
    #endif

    #if swift(>=3)
        public func emitChange<T: Store>(_ store: T) {
            eventListeners.forEach { (_, listener) -> () in
                if (listener.store === store) { listener.handler() }
            }
        }
    #else
        public func emitChange<T: Store>(store: T) {
            eventListeners.forEach { (_, listener) -> () in
                if (listener.store === store) { listener.handler() }
            }
        }
    #endif
}
