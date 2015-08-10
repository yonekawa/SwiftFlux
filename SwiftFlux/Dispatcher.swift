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
    private static let instance = Dispatcher()
    private var callbacks: Dictionary<String, AnyObject> = [:]
    private var _isDispatching = false
    private var lastDispatchIdentifier = 0
}

extension Dispatcher {
    public var isDispathing: Bool {
        get {
            return self._isDispatching
        }
    }

    public class func dispatch<T: Action>(action: T.Type, result: Result<T.Payload, NSError>) {
        instance.dispatch(action, result: result)
    }

    public class func register<T: Action>(action: T.Type, handler: (Result<T.Payload, NSError>) -> Void) -> String {
        return instance.register(action, handler: handler)
    }

    public class func unregister(identifier: String) {
        instance.unregister(identifier)
    }

    public class func waitFor<T: Action>(identifiers: Array<String>, action: T.Type, result: Result<T.Payload, NSError>) {
        instance.waitFor(identifiers, action: action, result: result)
    }
}

extension Dispatcher {
    private func dispatch<T: Action>(action: T.Type, result: Result<T.Payload, NSError>) {
        objc_sync_enter(self)
        
        self.startDispatching(action)
        for identifier in self.callbacks.keys {
            self.invokeCallback(identifier, action: action, result: result)
        }
        self.finishDispatching(action)
        
        objc_sync_exit(self)
    }
    
    private func register<T: Action>(action: T.Type, handler: (Result<T.Payload, NSError>) -> Void) -> String {
        let nextDispatchIdentifier = "DISPATCH_CALLBACK_\(++self.lastDispatchIdentifier)"
        self.callbacks[nextDispatchIdentifier] = DispatchCallback<T>(action: action, handler: handler)
        return nextDispatchIdentifier
    }

    private func unregister(identifier: String) {
        self.callbacks.removeValueForKey(identifier)
    }
    
    private func waitFor<T: Action>(identifiers: Array<String>, action: T.Type, result: Result<T.Payload, NSError>) {
        for identifier in identifiers {
            if let callback = self.callbacks[identifier] as? DispatchCallback<T> {
                switch callback.status {
                case .Handled:
                    continue
                case .Pending:
                    // Circular dependency detected while
                    continue
                default:
                    self.invokeCallback(identifier, action: action, result: result)
                }
            }
        }
    }
    
    private func startDispatching<T: Action>(action: T.Type) {
        self._isDispatching = true
        
        for (identifier, calllback) in self.callbacks {
            if let callback = self.callbacks[identifier] as? DispatchCallback<T> {
                callback.status = DispatchStatus.Waiting
            }
        }
    }
    
    private func finishDispatching<T: Action>(action: T.Type) {
        self._isDispatching = false
    }
    
    private func invokeCallback<T: Action>(identifier: String, action: T.Type, result: Result<T.Payload, NSError>) {
        if let callback = self.callbacks[identifier] as? DispatchCallback<T> {
            callback.status = DispatchStatus.Pending
            callback.handler(result)
            callback.status = DispatchStatus.Handled
        }
    }
}

internal class DispatchCallback<T: Action> {
    let action: T.Type
    let handler: (Result<T.Payload, NSError>) -> Void
    
    var status: DispatchStatus = DispatchStatus.Waiting
    
    init(action: T.Type, handler: (Result<T.Payload, NSError>) -> Void) {
        self.action = action
        self.handler = handler
    }
}

internal enum DispatchStatus {
    case Waiting
    case Pending
    case Handled
}
