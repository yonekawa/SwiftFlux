//
//  Store.swift
//  SwiftFlux
//
//  Created by Kenichi Yonekawa on 11/28/15.
//  Copyright © 2015 mog2dev. All rights reserved.
//

import Result

public protocol ReduxAction {}

public class ReduxStore<T: Equatable> {
    private let key: String
    private let initialState: T
    private let reducer: (T, ReduxAction) -> T

    public typealias EventListener = () -> ()
    private var eventListeners = [EventListener]()

    private var internalState: T?
    public var state: T {
        return internalState ?? initialState
    }

    deinit {
        self.eventListeners.removeAll()
    }

    init(key: String, initialState: T, reducer: (T, ReduxAction) -> T) {
        self.key = key
        self.initialState = initialState
        self.reducer = reducer
    }

    public func dispatch(action: ReduxAction) {
        let startState = self.state
        internalState = reducer(self.state, action)
        if startState != self.state {
            emitChange()
        }
    }

    public func subscribe(listener: EventListener) {
        eventListeners.append(listener)
    }
    
    public func emitChange() {
        eventListeners.forEach { (listener) in
            listener()
        }
    }
}

func createStore<T: Equatable>(initialState: T, reducer: (T, ReduxAction) -> T) -> ReduxStore<T> {
    return ReduxStore<T>(key: "1", initialState: initialState, reducer: reducer)
}

/*

enum CounterAction: ReduxAction {
    case Increment
    case Decrement
}

func counter(state: Int, action: ReduxAction) -> Int {
    guard let action = action as? CounterAction else { return state }

    switch action {
    case .Increment:
        return state + 1
    case .Decrement:
        return state - 1
    }
}

func main() {
    let store = StateTree.createStore(0, reducer: counter)
}
*/