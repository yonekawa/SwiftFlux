//
//  StoreBaseSpec.swift
//  SwiftFlux
//
//  Created by Kenichi Yonekawa on 11/20/15.
//  Copyright © 2015 mog2dev. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Result
import SwiftFlux

class StoreBaseSpec: QuickSpec {
    struct CalculateActions {
        struct Plus: Action {
            typealias Payload = Int
            let number: Int
            func invoke(dispatcher: Dispatcher) {
                dispatcher.dispatch(action: self, result: Result(value: number))
            }
        }
        struct Minus: Action {
            typealias Payload = Int
            let number: Int
            func invoke(dispatcher: Dispatcher) {
                dispatcher.dispatch(action: self, result: Result(value: number))
            }
        }
    }
    
    class CalculateStore: StoreBase {
        private(set) var number: Int = 0

        override init() {
            super.init()

            let _ = self.register(type: CalculateActions.Plus.self) { (result) in
                switch result {
                case .success(let value):
                    self.number += value
                    self.emitChange()
                default:
                    break
                }
            }
            
            let _ = self.register(type: CalculateActions.Minus.self) { (result) in
                switch result {
                case .success(let value):
                    self.number -= value
                    self.emitChange()
                default:
                    break
                }
            }
        }
    }

    override func spec() {
        let store = CalculateStore()
        var results = [Int]()

        beforeEach { () in
            results = []
            let _ = store.subscribe(store: store, handler: {
                results.append(store.number)
            })
        }

        afterEach { () in
            store.unregister()
        }

        it("should calculate state with number") {
            ActionCreator.invoke(action: CalculateActions.Plus(number: 3))
            ActionCreator.invoke(action: CalculateActions.Plus(number: 3))
            ActionCreator.invoke(action: CalculateActions.Minus(number: 2))
            ActionCreator.invoke(action: CalculateActions.Minus(number: 1))

            expect(results.count).to(equal(4))
            expect(results[0]).to(equal(3))
            expect(results[1]).to(equal(6))
            expect(results[2]).to(equal(4))
            expect(results[3]).to(equal(3))
        }
    }
}
