//
//  Redux.swift
//  SwiftFlux
//
//  Created by Kenichi Yonekawa on 11/28/15.
//  Copyright © 2015 mog2dev. All rights reserved.
//

public protocol ReduxAction {}
public typealias ReduxDispatcher = (ReduxAction) -> ()
public typealias ReduxActionCreator = (dispatch: ReduxDispatcher) -> ()

public class ReduxStore<T: Equatable> {
    private let initialState: T
    private let reducer: (T, ReduxAction) -> T

    public typealias Subscriber = () -> ()
    private var subscribers = [Subscriber]()

    private var internalState: T?
    public var state: T {
        return internalState ?? initialState
    }

    public static func create<T>(initialState: T, reducer: (T, ReduxAction) -> T) -> ReduxStore<T> {
        return ReduxStore<T>(initialState: initialState, reducer: reducer)
    }

    deinit {
        self.subscribers.removeAll()
    }

    init(initialState: T, reducer: (T, ReduxAction) -> T) {
        self.initialState = initialState
        self.reducer = reducer
    }

    public func dispatch(action: ReduxAction) {
        objc_sync_enter(self)

        let startState = self.state
        internalState = reducer(self.state, action)
        if startState != self.state {
            emitChange()
        }

        objc_sync_exit(self)
    }

    public func dispatch(actionCreator: ReduxActionCreator) {
        actionCreator(dispatch: self.dispatch)
    }

    public func subscribe(subscriber: Subscriber) {
        subscribers.append(subscriber)
    }

    private func emitChange() {
        subscribers.forEach { (subscriber) in subscriber() }
    }
}
