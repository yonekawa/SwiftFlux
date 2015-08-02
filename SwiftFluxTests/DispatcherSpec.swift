//
//  DispatcherSpec.swift
//  SwiftFlux
//
//  Created by Kenichi Yonekawa on 8/2/15.
//  Copyright (c) 2015 mog2dev. All rights reserved.
//

import Quick
import Nimble
import Box
import Result
import SwiftFlux

class DispatcherSpec: QuickSpec {
    override func spec() {
        struct TestModel {
            let name: String
        }
        
        describe("dispatch") {
            var results = [String]()
            var fails = [String]()
            var callbacks = [String]()

            class TestAction: Action {
                typealias Payload = TestModel
                func invoke() {}
            }

            beforeEach({ () -> () in
                results = []
                fails = []
                callbacks = []

                let id1 = Dispatcher.register(TestAction()) { (result) in
                    switch result {
                    case .Success(let box):
                        results.append("\(box.value.name)1")
                    case .Failure(let box):
                        fails.append("fail")
                    }
                }
                let id2 = Dispatcher.register(TestAction()) { (result) in
                    switch result {
                    case .Success(let box):
                        results.append("\(box.value.name)2")
                    case .Failure(let box):
                        fails.append("fail")
                    }
                }
                callbacks.append(id1)
                callbacks.append(id2)
            })

            afterEach({ () -> () in
                for id in callbacks {
                    Dispatcher.unregister(id)
                }
            })
            
            context("when action succeeded") {
                it("should dispatch to registered callback handlers") {
                    Dispatcher.dispatch(TestAction(), result: Result(value: TestModel(name: "test")))
                    expect(results.count).to(equal(2))
                    expect(fails.isEmpty).to(beTruthy())
                    expect(results).to(contain("test1", "test2"))
                }
            }
            
            context("when action failed") {
                it("should dispatch to registered callback handlers") {
                    Dispatcher.dispatch(TestAction(), result: Result(error: NSError()))
                    expect(fails.count).to(equal(2))
                    expect(results.isEmpty).to(beTruthy())
                }
            }
        }
    }
}