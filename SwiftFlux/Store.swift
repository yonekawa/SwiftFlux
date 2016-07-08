public typealias StoreListenerToken = String

private var EventEmitterObjectKey: UInt8 = 0

public protocol Store : AnyObject {}

extension Store {

    private var eventEmitter: EventEmitter {
        guard let eventEmitter = objc_getAssociatedObject(self, &EventEmitterObjectKey) as? EventEmitter else {
            let eventEmitter = DefaultEventEmitter()
            objc_setAssociatedObject(self, &EventEmitterObjectKey, eventEmitter, .OBJC_ASSOCIATION_RETAIN)
            return eventEmitter
        }
        return eventEmitter
    }

    #if swift(>=3)
        @discardableResult
        public func subscribe(handler: () -> ()) -> StoreListenerToken {
            return eventEmitter.subscribe(self, handler: handler)
        }
    #else
        public func subscribe(handler: () -> ()) -> StoreListenerToken {
            return eventEmitter.subscribe(self, handler: handler)
        }
    #endif


    #if swift(>=3)
        public func unsubscribe(_ listenerToken: StoreListenerToken) {
            eventEmitter.unsubscribe(self, listenerToken: listenerToken)
        }
    #else
        public func unsubscribe(listenerToken: StoreListenerToken) {
            eventEmitter.unsubscribe(self, listenerToken: listenerToken)
        }
    #endif

    public func unsubscribeAll() {
        eventEmitter.unsubscribe(self)
    }

    public func emitChange()  {
        eventEmitter.emitChange(self)
    }
}
