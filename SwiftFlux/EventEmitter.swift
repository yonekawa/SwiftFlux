//
//  EventEmitter.swift
//  SwiftFlux
//
//  Created by Kenichi Yonekawa on 8/2/15.
//  Copyright (c) 2015 mog2dev. All rights reserved.
//

import Foundation

public class EventEmitter {
    private static let instance = EventEmitter()
    private var listenes: Dictionary<String, AnyObject> = [:]
    private var lastId = 0
    private init() {}
}

extension EventEmitter {
    public class func listen<T: Store>(store: T, event: T.Event, handler: () -> Void) -> String {
        return self.instance.listen(store, event: event, handler: handler)
    }
    
    public class func emit<T: Store>(store: T, event: T.Event) {
        self.instance.emit(store, event: event)
    }
    
    public class func unlisten(id: String) {
        self.instance.unlisten(id)
    }
}

extension EventEmitter {
    private func listen<T: Store>(store: T, event: T.Event, handler: () -> Void) -> String {
        let nextId = "EVENT_LISTENER_\(++lastId)"
        self.listenes[nextId] = EventListener<T>(store: store, event: event, handler: handler)
        return nextId
    }
    
    private func emit<T: Store>(store: T, event: T.Event) {
        for (key, value) in self.listenes {
            if let listener = value as? EventListener<T> {
                if listener.event == event {
                    listener.handler()
                }
            }
        }
    }
    
    private func unlisten(id: String) {
        self.listenes.removeValueForKey(id)
    }
}

internal class EventListener<T: Store> {
    let store: T
    let event: T.Event
    let handler: () -> Void
    
    init(store: T, event: T.Event, handler: () -> Void) {
        self.store = store
        self.event = event
        self.handler = handler
    }
}