//
//  StoreBase.swift
//  SwiftFlux
//
//  Created by Kenichi Yonekawa on 11/20/15.
//  Copyright © 2015 mog2dev. All rights reserved.
//

import Result

public class StoreBase: Store {
    private var dispatchIdentifiers: [String] = []

    public init() {}

    public func register<T: Action>(type: T.Type, handler: (Result<T.Payload, T.Error>) -> ()) -> String {
        let identifier = ActionCreator.dispatcher.register(type) { (result) -> () in
            handler(result)
        }
        dispatchIdentifiers.append(identifier)

        return identifier
    }

    public func unregister() {
        dispatchIdentifiers.forEach { (identifier) -> () in
            ActionCreator.dispatcher.unregister(identifier)
        }
    }
}
