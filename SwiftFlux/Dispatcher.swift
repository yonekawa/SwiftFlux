//
//  Dispatcher.swift
//  SwiftFlux
//
//  Created by Kenichi Yonekawa on 7/31/15.
//  Copyright (c) 2015 mog2dev. All rights reserved.
//

import Foundation
import Result

public typealias DispatchToken = String

public protocol Dispatcher {
    func dispatch<T: Action>(action: T, result: Result<T.Payload, T.ActionError>)
    func register<T: Action>(type: T.Type, handler: @escaping (Result<T.Payload, T.ActionError>) -> Void) -> DispatchToken
    func unregister(dispatchToken: DispatchToken)
    func waitFor<T: Action>(dispatchTokens: [DispatchToken], type: T.Type, result: Result<T.Payload, T.ActionError>)
}

public class DefaultDispatcher: Dispatcher {
    internal enum Status {
        case Waiting
        case Pending
        case Handled
    }

    private var callbacks: [DispatchToken: AnyObject] = [:]

    public init() {}

    deinit {
        callbacks.removeAll()
    }

    public func dispatch<T: Action>(action: T, result: Result<T.Payload, T.ActionError>) {
        dispatch(type: type(of: action), result: result)
    }

    public func register<T: Action>(type: T.Type, handler: @escaping (Result<T.Payload, T.ActionError>) -> Void) -> DispatchToken {
        let nextDispatchToken = NSUUID().uuidString
        callbacks[nextDispatchToken] = DispatchCallback<T>(type: type, handler: handler)
        return nextDispatchToken
    }

    public func unregister(dispatchToken: DispatchToken) {
        callbacks.removeValue(forKey: dispatchToken)
    }

    public func waitFor<T: Action>(dispatchTokens: [DispatchToken], type: T.Type, result: Result<T.Payload, T.ActionError>) {
        for dispatchToken in dispatchTokens {
            guard let callback = callbacks[dispatchToken] as? DispatchCallback<T> else { continue }
            switch callback.status {
            case .Handled:
                continue
            case .Pending:
                // Circular dependency detected while
                continue
            default:
                invokeCallback(dispatchToken: dispatchToken, type: type, result: result)
            }
        }
    }

    private func dispatch<T: Action>(type: T.Type, result: Result<T.Payload, T.ActionError>) {
        objc_sync_enter(self)

        startDispatching(type: type)
        for dispatchToken in callbacks.keys {
            invokeCallback(dispatchToken: dispatchToken, type: type, result: result)
        }

        objc_sync_exit(self)
    }

    private func startDispatching<T: Action>(type: T.Type) {
        for (dispatchToken, _) in callbacks {
            guard let callback = callbacks[dispatchToken] as? DispatchCallback<T> else { continue }
            callback.status = .Waiting
        }
    }

    private func invokeCallback<T: Action>(dispatchToken: DispatchToken, type: T.Type, result: Result<T.Payload, T.ActionError>) {
        guard let callback = callbacks[dispatchToken] as? DispatchCallback<T> else { return }
        guard callback.status == .Waiting else { return }

        callback.status = .Pending
        callback.handler(result)
        callback.status = .Handled
    }
}

private class DispatchCallback<T: Action> {
    let type: T.Type
    let handler: (Result<T.Payload, T.ActionError>) -> ()
    var status = DefaultDispatcher.Status.Waiting

    init(type: T.Type, handler: @escaping (Result<T.Payload, T.ActionError>) -> ()) {
        self.type = type
        self.handler = handler
    }
}
