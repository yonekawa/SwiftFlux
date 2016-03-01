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
    final class TestStore: Store {}
    final class TestStore2: Store {}

    override func spec() {
        let store = TestStore()
        let store2 = TestStore2()

        describe("emitChange") {
            var unsubscribeIdentifier = ""
            var results = [String]()

            beforeEach { () in
                results = []
                store.subscribe { () in
                    results.append("test 1")
                }
                unsubscribeIdentifier = store.subscribe { () in
                    results.append("test 2")
                }
                store2.subscribe { () in
                    results.append("test2 1")
                }
            }

            afterEach { () in
                store.unsubscribeAll()
            }

            it("should fire event correctly") {
                store.emitChange()
                expect(results.count).to(equal(2))
                expect(results[0]).to(equal("test 2"))
                expect(results[1]).to(equal("test 1"))

                store.unsubscribe(unsubscribeIdentifier)
                store.emitChange()
                expect(results.count).to(equal(3))
                expect(results[0]).to(equal("test 2"))
                expect(results[1]).to(equal("test 1"))
                expect(results[2]).to(equal("test 1"))

                store2.emitChange()
                expect(results.count).to(equal(4))
                expect(results[0]).to(equal("test 2"))
                expect(results[1]).to(equal("test 1"))
                expect(results[2]).to(equal("test 1"))
                expect(results[3]).to(equal("test2 1"))
            }
        }
    }
}
