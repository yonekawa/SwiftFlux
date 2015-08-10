//
//  EventEmitter.swift
//  SwiftFlux
//
//  Created by Kenichi Yonekawa on 8/2/15.
//  Copyright (c) 2015 mog2dev. All rights reserved.
//

import Foundation

public class EventEmitter {
    private var eventListeners: Dictionary<String, AnyObject> = [:]
    private var lastListenerIdentifier = 0

    public init() {}
    deinit {
        self.eventListeners.removeAll()
    }
}

extension EventEmitter {
    public func listen<T: Store>(store: T, event: T.Event, handler: () -> Void) -> String {
        let nextListenerIdentifier = "EVENT_LISTENER_\(++lastListenerIdentifier)"
        self.eventListeners[nextListenerIdentifier] = EventListener<T>(event: event, handler: handler)
        return nextListenerIdentifier
    }

    public func emit<T: Store>(store: T, event: T.Event) {
        for (key, value) in self.eventListeners {
            if let listener = value as? EventListener<T> {
                if listener.event == event {
                    listener.handler()
                }
            }
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