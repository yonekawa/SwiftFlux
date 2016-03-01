//
//  DispatcherSpec.swift
//  SwiftFlux
//
//  Created by Kenichi Yonekawa on 8/2/15.
//  Copyright (c) 2015 mog2dev. All rights reserved.
//

import Quick
import Nimble
import Result
import SwiftFlux

class DispatcherSpec: QuickSpec {
    struct DispatcherTestModel {
        let name: String
    }

    struct DispatcherTestAction: Action {
        typealias Payload = DispatcherTestModel
        func invoke(dispatcher: Dispatcher) {}
    }
    
    override func spec() {
        let dispatcher = DefaultDispatcher()

        describe("dispatch") {
            var results = [String]()
            var fails = [String]()
            var callbacks = [DispatchToken]()

            beforeEach { () in
                results = []
                fails = []
                callbacks = []

                let id1 = dispatcher.register(DispatcherTestAction.self) { (result) in
                    switch result {
                    case .Success(let box):
                        results.append("\(box.name)1")
                    case .Failure(_):
                        fails.append("fail")
                    }
                }
                let id2 = dispatcher.register(DispatcherTestAction.self) { (result) in
                    switch result {
                    case .Success(let box):
                        results.append("\(box.name)2")
                    case .Failure(_):
                        fails.append("fail")
                    }
                }
                callbacks.append(id1)
                callbacks.append(id2)
            }

            afterEach { () in
                for id in callbacks {
                    dispatcher.unregister(id)
                }
            }
            
            context("when action succeeded") {
                it("should dispatch to registered callback handlers") {
                    dispatcher.dispatch(DispatcherTestAction(), result: Result(value: DispatcherTestModel(name: "test")))
                    expect(results.count).to(equal(2))
                    expect(fails.isEmpty).to(beTruthy())
                    expect(results).to(contain("test1", "test2"))
                }
            }
            
            context("when action failed") {
                it("should dispatch to registered callback handlers") {
                    dispatcher.dispatch(DispatcherTestAction(), result: Result(error: NSError(domain: "TEST0000", code: -1, userInfo: [:])))
                    expect(fails.count).to(equal(2))
                    expect(results.isEmpty).to(beTruthy())
                }
            }
        }

        describe("waitFor") {
            var results = [String]()
            var callbacks = [DispatchToken]()
            var id1 = "";
            var id2 = "";
            var id3 = "";

            beforeEach { () in
                results = []
                callbacks = []

                id1 = dispatcher.register(DispatcherTestAction.self) { (result) in
                    switch result {
                    case .Success(let box):
                        dispatcher.waitFor([id2], type: DispatcherTestAction.self, result: result)
                        results.append("\(box.name)1")
                    default:
                        break
                    }
                }
                id2 = dispatcher.register(DispatcherTestAction.self) { (result) in
                    switch result {
                    case .Success(let box):
                        dispatcher.waitFor([id3], type: DispatcherTestAction.self, result: result)
                        results.append("\(box.name)2")
                    default:
                        break
                    }
                }
                id3 = dispatcher.register(DispatcherTestAction.self) { (result) in
                    switch result {
                    case .Success(let box):
                        results.append("\(box.name)3")
                    default:
                        break
                    }
                }
                callbacks.append(id1)
                callbacks.append(id2)
                callbacks.append(id3)
            }

            afterEach { () in
                for id in callbacks {
                    dispatcher.unregister(id)
                }
            }

            it("should wait for invoke callback") {
                dispatcher.dispatch(DispatcherTestAction(), result: Result(value: DispatcherTestModel(name: "test")))
                expect(results.count).to(equal(3))
                expect(results[0]).to(equal("test3"))
                expect(results[1]).to(equal("test2"))
                expect(results[2]).to(equal("test1"))
            }
        }
    }
}
