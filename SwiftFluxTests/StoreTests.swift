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
        XCTAssertNotNil(results.indexOf("store1"))

        store1.emitChange()
        XCTAssertEqual(results.count, 2)
        XCTAssertNotNil(results.indexOf("store1"))

        store2.emitChange()
        XCTAssertEqual(results.count,3)
        XCTAssertNotNil(results.indexOf("store2"))
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
        XCTAssertNotNil(results.indexOf("store1"))

        results = []

        store1.unsubscribe(token)
        store1.emitChange()
        XCTAssertEqual(results.count, 0)
        XCTAssertNil(results.indexOf("store1"))
    }
}
