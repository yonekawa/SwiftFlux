//
//  StoreBase.swift
//  SwiftFlux
//
//  Created by Kenichi Yonekawa on 11/20/15.
//  Copyright © 2015 mog2dev. All rights reserved.
//

import Result

open class StoreBase: Store {
    private var dispatchTokens: [DispatchToken] = []

    public init() {}

    public func register<T: Action>(type: T.Type, handler: @escaping (Result<T.Payload, T.ActionError>) -> ()) -> DispatchToken {
        let dispatchToken = ActionCreator.dispatcher.register(type: type) { (result) -> () in
            handler(result)
        }
        dispatchTokens.append(dispatchToken)
        return dispatchToken
    }

    public func unregister() {
        dispatchTokens.forEach { (dispatchToken) -> () in
            ActionCreator.dispatcher.unregister(dispatchToken: dispatchToken)
        }
    }
}
