import XCTest
@testable import SwiftFlux

class StoreEmitChangeTests: XCTestCase {
    final class TestStore1: Store {}
    final class TestStore2: Store {}

    let store1 = TestStore1()
    let store2 = TestStore2()

    var results = [String]()

    override func setUp() {
        results = []
        store1.subscribe { () in
            self.results.append("store1")
        }
        store2.subscribe { () in
            self.results.append("store2")
        }
    }

    override func tearDown() {
        store1.unsubscribeAll()
        store2.unsubscribeAll()
    }

    func testShoulFireEventCorrectly() {
        store1.emitChange()
        XCTAssertEqual(results.count, 1)
        #if swift(>=3)
            XCTAssertNotNil(results.index(of: "store1"))
        #else
            XCTAssertNotNil(results.indexOf("store1"))
        #endif

        store1.emitChange()
        XCTAssertEqual(results.count, 2)
        #if swift(>=3)
            XCTAssertNil(results.index(of: "store2"))
        #else
            XCTAssertNil(results.indexOf("store2"))
        #endif

        store2.emitChange()
        XCTAssertEqual(results.count, 3)
        #if swift(>=3)
            XCTAssertNotNil(results.index(of: "store2"))
        #else
            XCTAssertNotNil(results.indexOf("store2"))
        #endif
    }
}

class StoreUnsubscribeTests: XCTestCase {
    final class TestStore1: Store {}
    final class TestStore2: Store {}

    let store1 = TestStore1()
    let store2 = TestStore2()

    var results = [String]()
    var token = ""

    override func setUp() {
        results = []
        token = store1.subscribe { () in
            self.results.append("store1")
        }
    }

    override func tearDown() {
        store1.unsubscribeAll()
        store2.unsubscribeAll()
    }

    func testShouldUnsubscribeCollectly() {
        store1.emitChange()
        XCTAssertEqual(results.count, 1)
        #if swift(>=3)
            XCTAssertNotNil(results.index(of: "store1"))
        #else
            XCTAssertNotNil(results.indexOf("store1"))
        #endif

        results = []

        #if swift(>=3)
            store1.unsubscribe(token)
        #else
            store1.unsubscribe(token)
        #endif
        store1.emitChange()
        XCTAssertEqual(results.count, 0)
        #if swift(>=3)
            XCTAssertNil(results.index(of: "store1"))
        #else
            XCTAssertNil(results.indexOf("store1"))
        #endif
    }
}
