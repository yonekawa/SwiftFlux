//
//  ReduceStore.swift
//  SwiftFlux
//
//  Created by Kenichi Yonekawa on 11/18/15.
//  Copyright © 2015 mog2dev. All rights reserved.
//

import Result

public enum ReduceStoreEvent: Int {
    case Changed
}

public class ReduceStore<T: Equatable>: Store {
    public typealias Event = ReduceStoreEvent
    public let eventEmitter = EventEmitter<ReduceStore<T>>()

    public init() {}
    
    private var internalState: T?
    public var state: T {
        return internalState ?? initialState
    }

    public var initialState: T {
        fatalError("\(self.dynamicType) has not overridden ReduceStore.initialState, which is required")
    }

    public func reduce<A: Action>(type: A.Type, reducer: (T, Result<A.Payload, A.Error>) -> T) -> String {
        return ActionCreator.dispatcher.register(type) { (result) in
            let startState = self.state
            self.internalState = reducer(self.state, result)
            if startState != self.state {
                self.eventEmitter.emit(.Changed)
            }
        }
    }
}

