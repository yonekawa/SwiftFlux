//
//  Store.swift
//  SwiftFlux
//
//  Created by Kenichi Yonekawa on 7/31/15.
//  Copyright (c) 2015 mog2dev. All rights reserved.
//

import Foundation

public protocol Store : AnyObject {
}

private var EventEmitterObjectKey: UInt8 = 0

extension Store {
    public var eventEmitter: EventEmitter {
        guard let eventEmitter = objc_getAssociatedObject(self, &EventEmitterObjectKey) as? EventEmitter else {
            let eventEmitter = DefaultEventEmitter()
            objc_setAssociatedObject(self, &EventEmitterObjectKey, eventEmitter, .OBJC_ASSOCIATION_RETAIN)
            return eventEmitter
        }
        return eventEmitter
    }

    public func subscribe(handler: () -> ()) -> String {
        return eventEmitter.subscribe(self, handler: handler)
    }

    public func unsubscribe(identifier: String) {
        eventEmitter.unsubscribe(self, identifier: identifier)
    }

    public func unsubscribeAll() {
        eventEmitter.unsubscribe(self)
    }

    public func emitChange()  {
        eventEmitter.emitChange(self)
    }
}

public protocol EventEmitter {
    func subscribe<T: Store>(store: T, handler: () -> ()) -> String
    func unsubscribe<T: Store>(store: T)
    func unsubscribe<T: Store>(store: T, identifier: String)
    func emitChange<T: Store>(store: T)
}

public class DefaultEventEmitter: EventEmitter {
    private var eventListeners: Dictionary<String, EventListener> = [:]
    private var lastListenerIdentifier = 0

    public init() {}
    deinit {
        self.eventListeners.removeAll()
    }

    public func subscribe<T: Store>(store: T, handler: () -> ()) -> String {
        let nextListenerIdentifier = "EVENT_LISTENER_\(++lastListenerIdentifier)"
        self.eventListeners[nextListenerIdentifier] = EventListener(store: store, handler: handler)
        return nextListenerIdentifier
    }

    public func unsubscribe<T: Store>(store: T) {
        self.eventListeners.forEach({ (identifier, listener) -> () in
            if (listener.store === store) {
                self.eventListeners.removeValueForKey(identifier)
            }
        })
    }

    public func unsubscribe<T: Store>(store: T, identifier: String) {
        self.eventListeners.removeValueForKey(identifier)
    }

    public func emitChange<T: Store>(store: T) {
        self.eventListeners.forEach({ (_, listener) -> () in
            if (listener.store === store) { listener.handler() }
        })
    }
}

private class EventListener {
    let store: Store
    let handler: () -> ()

    init(store: Store, handler: () -> ()) {
        self.store = store
        self.handler = handler
    }
}
