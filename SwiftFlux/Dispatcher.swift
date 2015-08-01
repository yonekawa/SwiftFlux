//
//  Dispatcher.swift
//  SwiftFlux
//
//  Created by Kenichi Yonekawa on 7/31/15.
//  Copyright (c) 2015 mog2dev. All rights reserved.
//

import Foundation
import Result

internal enum CallbackStatus<T: Action> {
    case Waiting
    case Pending
    case Handled
}

internal class Callback<T: Action> {
    let action: T
    let handler: (Result<T.Payload, NSError>) -> Void

    var status: CallbackStatus<T> = CallbackStatus.Waiting

    init(action: T, handler: (Result<T.Payload, NSError>) -> Void) {
        self.action = action
        self.handler = handler
    }
}

public class Dispatcher {
    private static let instance = Dispatcher()
    private var callbacks: Dictionary<String, AnyObject> = [:]
    private var _isDispatching = false
    private var lastId = 0
    private init() {}
}

// Public interfaces
extension Dispatcher {
    public var isDispathing: Bool {
        get {
            return self._isDispatching
        }
    }
    
    public class func dispatch<T: Action>(action: T, result: Result<T.Payload, NSError>) {
        instance.dispatch(action, result: result)
    }

    public class func register<T: Action>(action: T, handler: (Result<T.Payload, NSError>) -> Void) {
        instance.register(action, handler: handler)
    }
    
    public class func waitFor<T: Action>(ids: Array<String>, action: T, result: Result<T.Payload, NSError>) {
        instance.waitFor(ids, action: action, result: result)
    }
}

// Private implementation
extension Dispatcher {
    private func dispatch<T: Action>(action: T, result: Result<T.Payload, NSError>) {
        objc_sync_enter(self)
        
        self.startDispatching(action)
        for id in self.callbacks.keys {
            self.invokeCallback(id, action: action, result: result)
        }
        self.finishDispatching(action)
        
        objc_sync_exit(self)
    }
    
    private func register<T: Action>(action: T, handler: (Result<T.Payload, NSError>) -> Void) -> String {
        let nextId = "ID_\(++self.lastId)"
        self.callbacks[nextId] = Callback<T>(action: action, handler: handler)
        return nextId
    }
    
    private func waitFor<T: Action>(ids: Array<String>, action: T, result: Result<T.Payload, NSError>) {
        for id in ids {
            if let callback = self.callbacks[id] as? Callback<T> {
                switch callback.status {
                case .Pending:
                    // Circular dependency detected while
                    continue
                case .Handled:
                    continue
                default:
                    self.invokeCallback(id, action: action, result: result)
                }
            }
        }
    }
    
    private func startDispatching<T: Action>(action: T) {
        self._isDispatching = true
        
        for (id, calllback) in self.callbacks {
            if let callback = self.callbacks[id] as? Callback<T> {
                callback.status = CallbackStatus.Waiting
            }
        }
    }
    
    private func finishDispatching<T: Action>(action: T) {
        self._isDispatching = false
    }
    
    private func invokeCallback<T: Action>(id: String, action: T, result: Result<T.Payload, NSError>) {
        if let callback = self.callbacks[id] as? Callback<T> {
            callback.status = CallbackStatus.Pending
            callback.handler(result)
            callback.status = CallbackStatus.Handled
        }
    }
}