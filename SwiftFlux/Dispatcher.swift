//
//  Dispatcher.swift
//  SwiftFlux
//
//  Created by Kenichi Yonekawa on 7/31/15.
//  Copyright (c) 2015 mog2dev. All rights reserved.
//

import Foundation
import Result

public protocol Dispatcher {
    func dispatch<T: Action>(action: T, result: Result<T.Payload, T.Error>)
    func register<T: Action>(type: T.Type, handler: (Result<T.Payload, T.Error>) -> Void) -> String
    func unregister(identifier: String)
    func waitFor<T: Action>(identifiers: Array<String>, type: T.Type, result: Result<T.Payload, T.Error>)
}

public class DefaultDispatcher: Dispatcher {
    private var callbacks: Dictionary<String, AnyObject> = [:]
    private var lastDispatchIdentifier = 0

    public init() {}

    deinit {
        self.callbacks.removeAll()
    }

    public func dispatch<T: Action>(action: T, result: Result<T.Payload, T.Error>) {
        self.dispatch(action.dynamicType, result: result)
    }

    public func register<T: Action>(type: T.Type, handler: (Result<T.Payload, T.Error>) -> Void) -> String {
        let nextDispatchIdentifier = "DISPATCH_CALLBACK_\(++self.lastDispatchIdentifier)"
        self.callbacks[nextDispatchIdentifier] = DispatchCallback<T>(type: type, handler: handler)
        return nextDispatchIdentifier
    }

    public func unregister(identifier: String) {
        self.callbacks.removeValueForKey(identifier)
    }

    public func waitFor<T: Action>(identifiers: Array<String>, type: T.Type, result: Result<T.Payload, T.Error>) {
        for identifier in identifiers {
            guard let callback = self.callbacks[identifier] as? DispatchCallback<T> else { continue }
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

    private func dispatch<T: Action>(type: T.Type, result: Result<T.Payload, T.Error>) {
        objc_sync_enter(self)

        self.startDispatching(type)
        for identifier in self.callbacks.keys {
            self.invokeCallback(identifier, type: type, result: result)
        }

        objc_sync_exit(self)
    }

    private func startDispatching<T: Action>(type: T.Type) {
        for (identifier, _) in self.callbacks {
            guard let callback = self.callbacks[identifier] as? DispatchCallback<T> else { continue }
            callback.status = .Waiting
        }
    }

    private func invokeCallback<T: Action>(identifier: String, type: T.Type, result: Result<T.Payload, T.Error>) {
        guard let callback = self.callbacks[identifier] as? DispatchCallback<T> else { return }
        guard callback.status == .Waiting else { return }

        callback.status = .Pending
        callback.handler(result)
        callback.status = .Handled
    }
}

internal class DispatchCallback<T: Action> {
    let type: T.Type
    let handler: (Result<T.Payload, T.Error>) -> Void

    var status: DispatchStatus = DispatchStatus.Waiting

    init(type: T.Type, handler: (Result<T.Payload, T.Error>) -> Void) {
        self.type = type
        self.handler = handler
    }
}

internal enum DispatchStatus {
    case Waiting
    case Pending
    case Handled
}
