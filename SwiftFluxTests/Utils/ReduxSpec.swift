//
//  ReduxSpec.swift
//  SwiftFlux
//
//  Created by Kenichi Yonekawa on 11/28/15.
//  Copyright © 2015 mog2dev. All rights reserved.
//

import Quick
import Nimble
import Result
import SwiftFlux

class ReduxSpec: QuickSpec {
    enum CounterAction: ReduxAction {
        case Increment
        case Decrement
    }

    enum FetchAction: ReduxAction {
        case Receive(String)
    }
    
    func counterReducer(state: Int, action: ReduxAction) -> Int {
        guard let action = action as? CounterAction else { return state }

        switch action {
        case .Increment:
            return state + 1
        case .Decrement:
            return state - 1
        }
    }

    func fetchActionCreator(dispatch: ReduxDispatcher) {
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue) { () in
            dispatch_async(dispatch_get_main_queue()) { () in
                dispatch(FetchAction.Receive("Data"))
            }
        }
    }

    func receiverReducer(state: String, action: ReduxAction) -> String {
        guard let action = action as? FetchAction else { return state }

        switch action {
        case .Receive(let data):
            return data
        }
    }

    override func spec() {
        describe("with Action") {
            it("should reduce counter state") {
                let initialState = 0
                let store = ReduxStore<Int>.create(initialState, reducer: self.counterReducer)
                expect(store.state).to(equal(0))
                store.dispatch(CounterAction.Increment)
                expect(store.state).to(equal(1))
                store.dispatch(CounterAction.Increment)
                expect(store.state).to(equal(2))
                store.dispatch(CounterAction.Decrement)
                expect(store.state).to(equal(1))
            }
        }

        describe("with ActionCreator") {
            it("should reduce receiver state asynchronously") {
                let initialState = ""
                let store = ReduxStore<String>.create(initialState, reducer: self.receiverReducer)
                expect(store.state).to(equal(""))

                self.fetchActionCreator(store.dispatch)
                expect(store.state).toEventually(equal("Data"))
            }
        }

        describe("subscribe") {
            it("should call subscriber function") {
                var results = [Int]()
                let initialState = 0
                let store = ReduxStore<Int>.create(initialState, reducer: self.counterReducer)

                store.subscribe { () in
                    results.append(store.state)
                }
                store.dispatch(CounterAction.Increment)
                store.dispatch(CounterAction.Increment)
                store.dispatch(CounterAction.Decrement)
                store.dispatch(CounterAction.Decrement)
                expect(results[0]).to(equal(1))
                expect(results[1]).to(equal(2))
                expect(results[2]).to(equal(1))
                expect(results[3]).to(equal(0))
            }
        }
    }
}
