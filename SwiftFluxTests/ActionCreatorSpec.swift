//
//  ActionCreatorSpec.swift
//  SwiftFlux
//
//  Created by Kenichi Yonekawa on 8/11/15.
//  Copyright (c) 2015 mog2dev. All rights reserved.
//

import Quick
import Nimble
import Box
import Result
import SwiftFlux

class ActionCreatorSpec: QuickSpec {
    override func spec() {
        struct TestModel {
            let name: String
        }

        class TestAction: Action {
            typealias Payload = TestModel
            func invoke(dispatcher: Dispatcher) {
                dispatcher.dispatch(self, result: Result(value: TestModel(name: "test")))
            }
        }

        class ErrorAction: Action {
            typealias Payload = TestModel
            func invoke(dispatcher: Dispatcher) {
                dispatcher.dispatch(self, result: Result(error: NSError()))
            }
        }

        describe("invoke", { () -> Void in
            var results = [String]()
            var fails = [String]()
            var callbacks = [String]()

            beforeEach({ () -> () in
                results = []
                fails = []
                callbacks = []
                
                let id1 = ActionCreator.dispatcher.register(TestAction.self) { (result) in
                    switch result {
                    case .Success(let box):
                        results.append("\(box.value.name)1")
                    case .Failure(let box):
                        fails.append("fail1")
                    }
                }
                let id2 = ActionCreator.dispatcher.register(ErrorAction.self) { (result) in
                    switch result {
                    case .Success(let box):
                        results.append("\(box.value.name)2")
                    case .Failure(let box):
                        fails.append("fail2")
                    }
                }
                callbacks.append(id1)
                callbacks.append(id2)
            })
            
            afterEach({ () -> () in
                for id in callbacks {
                    ActionCreator.dispatcher.unregister(id)
                }
            })
            
            context("when action succeeded") {
                it("should dispatch to registered callback handlers") {
                    let action = TestAction()
                    ActionCreator.invoke(action)

                    expect(results.count).to(equal(1))
                    expect(fails.isEmpty).to(beTruthy())
                    expect(results).to(contain("test1"))
                }
            }
            
            context("when action failed") {
                it("should dispatch to registered callback handlers") {
                    let action = ErrorAction()
                    ActionCreator.invoke(action)

                    expect(fails.count).to(equal(1))
                    expect(results.isEmpty).to(beTruthy())
                    expect(fails).to(contain("fail2"))
                }
            }
        })
    }
}