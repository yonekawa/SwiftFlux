//
//  StoreSpec.swift
//  SwiftFlux
//
//  Created by Kenichi Yonekawa on 8/2/15.
//  Copyright (c) 2015 mog2dev. All rights reserved.
//

import Quick
import Nimble
import Result
import SwiftFlux

class StoreSpec: QuickSpec {
    final class TestStore1: Store {}
    final class TestStore2: Store {}

    override func spec() {
        let store1 = TestStore1()
        let store2 = TestStore2()

        describe("emitChange") {
            var results = [String]()

            beforeEach { () in
                results = []
                store1.subscribe { () in
                    results.append("store1")
                }
                store2.subscribe { () in
                    results.append("store2")
                }
            }

            afterEach { () in
                store1.unsubscribeAll()
                store2.unsubscribeAll()
            }

            it("should fire event correctly") {
                store1.emitChange()
                expect(results.count).to(equal(1))
                expect(results).to(contain("store1"))

                store1.emitChange()
                expect(results.count).to(equal(2))
                expect(results).to(contain("store1"))

                store2.emitChange()
                expect(results.count).to(equal(3))
                expect(results).to(contain("store2"))
            }
        }

        describe("unsubscribe") {
            var results = [String]()
            var token = ""

            beforeEach { () in
                results = []
                token = store1.subscribe { () in
                    results.append("store1")
                }
            }

            afterEach { () in
                store1.unsubscribeAll()
                store2.unsubscribeAll()
            }

            it("should unsubscribe collectly") {
                store1.emitChange()
                expect(results.count).to(equal(1))
                expect(results).to(contain("store1"))

                results = []

                store1.unsubscribe(token)
                store1.emitChange()
                expect(results.count).to(equal(0))
                expect(results).toNot(contain("store1"))
            }
        }
    }
}
