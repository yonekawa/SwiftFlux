//
//  Dispatcher.swift
//  SwiftFlux
//
//  Created by Kenichi Yonekawa on 7/31/15.
//  Copyright (c) 2015 mog2dev. All rights reserved.
//

import Foundation
import Result

public class Dispatcher {
    private var callbacks: Dictionary<String, AnyObject> = [:]
    private var _isDispatching = false
    private var lastDispatchIdentifier = 0

    public init() {}

    deinit {
        self.callbacks.removeAll()
    }

    public func dispatch<T: Action>(action: T, result: Result<T.Payload, NSError>) {
        self.dispatch(action.dynamicType, result: result)
    }

    public func dispatch<T: Action>(type: T.Type, result: Result<T.Payload, NSError>) {
        objc_sync_enter(self)

        self.startDispatching(type)
        for identifier in self.callbacks.keys {
            self.invokeCallback(identifier, type: type, result: result)
        }
        self.finishDispatching()
        
        objc_sync_exit(self)
    }
    
    public func register<T: Action>(type: T.Type, handler: (Result<T.Payload, NSError>) -> Void) -> String {
        let nextDispatchIdentifier = "DISPATCH_CALLBACK_\(++self.lastDispatchIdentifier)"
        self.callbacks[nextDispatchIdentifier] = DispatchCallback<T>(type: type, handler: handler)
        return nextDispatchIdentifier
    }

    public func unregister(identifier: String) {
        self.callbacks.removeValueForKey(identifier)
    }
    
    public func waitFor<T: Action>(identifiers: Array<String>, type: T.Type, result: Result<T.Payload, NSError>) {
        for identifier in identifiers {
            if let callback = self.callbacks[identifier] as? DispatchCallback<T> {
                switch callback.status {
                case .Handled:
                    continue
                case .Pending:
                    // Circular dependency detected while
                    continue
                default:
                    self.invokeCallback(identifier, type: type, result: result)
                }
            }
        }
    }
    
    private func startDispatching<T: Action>(type: T.Type) {
        self._isDispatching = true
        
        for (identifier, calllback) in self.callbacks {
            if let callback = self.callbacks[identifier] as? DispatchCallback<T> {
                callback.status = DispatchStatus.Waiting
            }
        }
    }
    
    private func finishDispatching() {
        self._isDispatching = false
    }
    
    private func invokeCallback<T: Action>(identifier: String, type: T.Type, result: Result<T.Payload, NSError>) {
        if let callback = self.callbacks[identifier] as? DispatchCallback<T> {
            callback.status = DispatchStatus.Pending
            callback.handler(result)
            callback.status = DispatchStatus.Handled
        }
    }
}

internal class DispatchCallback<T: Action> {
    let type: T.Type
    let handler: (Result<T.Payload, NSError>) -> Void
    
    var status: DispatchStatus = DispatchStatus.Waiting
    
    init(type: T.Type, handler: (Result<T.Payload, NSError>) -> Void) {
        self.type = type
        self.handler = handler
    }
}

internal enum DispatchStatus {
    case Waiting
    case Pending
    case Handled
}
