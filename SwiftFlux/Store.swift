//
//  Store.swift
//  SwiftFlux
//
//  Created by Kenichi Yonekawa on 7/31/15.
//  Copyright (c) 2015 mog2dev. All rights reserved.
//

import Foundation

public protocol Store {
    typealias Event: Equatable
}

public class EventEmitter<T: Store> {
    private var eventListeners: Dictionary<String, AnyObject> = [:]
    private var lastListenerIdentifier = 0

    public init() {}
    deinit {
        self.eventListeners.removeAll()
    }

    public func listen(event: T.Event, handler: () -> Void) -> String {
        let nextListenerIdentifier = "EVENT_LISTENER_\(++lastListenerIdentifier)"
        self.eventListeners[nextListenerIdentifier] = EventListener<T>(event: event, handler: handler)
        return nextListenerIdentifier
    }

    public func emit(event: T.Event) {
        for (_, value) in self.eventListeners {
            guard let listener = value as? EventListener<T> else { continue }
            guard listener.event == event else { continue }
            listener.handler()
        }
    }

    public func unlisten(identifier: String) {
        self.eventListeners.removeValueForKey(identifier)
    }
}

internal class EventListener<T: Store> {
    let event: T.Event
    let handler: () -> Void

    init(event: T.Event, handler: () -> Void) {
        self.event = event
        self.handler = handler
    }
}
