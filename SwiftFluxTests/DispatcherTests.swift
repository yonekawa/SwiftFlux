import XCTest
@testable import SwiftFlux

class DispatcherSpec: XCTestCase {
    struct DispatcherTestModel {
        let name: String
    }

    struct DispatcherTestAction: Action {
        typealias Payload = DispatcherTestModel

        #if swift(>=3)
            func invoke(_ dispatcher: Dispatcher) {}
        #else
            func invoke(dispatcher: Dispatcher) {}
        #endif
    }
}

class DispatcherDispatchTests: XCTestCase {

    struct DispatcherTestModel {
        let name: String
    }

    struct DispatcherTestAction: Action {
        typealias Payload = DispatcherTestModel

        #if swift(>=3)
            func invoke(_ dispatcher: Dispatcher) {}
        #else
            func invoke(dispatcher: Dispatcher) {}
        #endif
    }

    let dispatcher = DefaultDispatcher()

    var results = [String]()
    var fails = [String]()
    var callbacks = [DispatchToken]()

    override func setUp() {
        results = []
        fails = []
        callbacks = []

        let id1 = dispatcher.register(DispatcherTestAction.self) { (result) in
            switch result {
            case .Success(let box):
                self.results.append("\(box.name)1")
            case .Failure(_):
                self.fails.append("fail")
            }
        }
        let id2 = dispatcher.register(DispatcherTestAction.self) { (result) in
            switch result {
            case .Success(let box):
                self.results.append("\(box.name)2")
            case .Failure(_):
                self.fails.append("fail")
            }
        }
        callbacks.append(id1)
        callbacks.append(id2)
    }

    override func tearDown() {
        for id in callbacks {
            dispatcher.unregister(id)
        }
    }

    func testWhenActionSucceeded() {
        // it should dispatch to registered callback handlers
        dispatcher.dispatch(
            DispatcherTestAction(),
            result: Result(value: DispatcherTestModel(name: "test")))

        XCTAssertEqual(results.count, 2)
        XCTAssert(fails.isEmpty)
        #if swift(>=3)
            XCTAssertNotNil(results.index(of: "test1"))
            XCTAssertNotNil(results.index(of: "test2"))
        #else
            XCTAssertNotNil(results.indexOf("test1"))
            XCTAssertNotNil(results.indexOf("test2"))
        #endif
    }

    func testActionFailed() {
        // it should dispatch to registered callback handlers
        dispatcher.dispatch(
            DispatcherTestAction(),
            result: Result(error: NSError(domain: "TEST0000", code: -1, userInfo: [:])))

        XCTAssertEqual(fails.count, 2)
        XCTAssert(results.isEmpty)
    }
}

class DispatcherWaitForTests: XCTestCase {

    struct DispatcherTestModel {
        let name: String
    }

    struct DispatcherTestAction: Action {
        typealias Payload = DispatcherTestModel

        #if swift(>=3)
            func invoke(_ dispatcher: Dispatcher) {}
        #else
            func invoke(dispatcher: Dispatcher) {}
        #endif
    }

    let dispatcher = DefaultDispatcher()
    
    var results = [String]()
    var callbacks = [DispatchToken]()
    var id1 = "";
    var id2 = "";
    var id3 = "";

    override func setUp() {

        results = []
        callbacks = []

        id1 = dispatcher.register(DispatcherTestAction.self) { (result) in
            switch result {
            case .Success(let box):
                self.dispatcher.waitFor(
                    [self.id2], type: DispatcherTestAction.self, result: result)
                self.results.append("\(box.name)1")
            default:
                break
            }
        }
        id2 = dispatcher.register(DispatcherTestAction.self) { (result) in
            switch result {
            case .Success(let box):
                self.dispatcher.waitFor(
                    [self.id3], type: DispatcherTestAction.self, result: result)
                self.results.append("\(box.name)2")
            default:
                break
            }
        }
        id3 = dispatcher.register(DispatcherTestAction.self) { (result) in
            switch result {
            case .Success(let box):
                self.results.append("\(box.name)3")
            default:
                break
            }
        }
        callbacks.append(id1)
        callbacks.append(id2)
        callbacks.append(id3)
    }

    override func tearDown() {
        for id in callbacks {
            dispatcher.unregister(id)
        }
    }

    func testWaitForInvokeCallback() {
        // it should wait for invoke callback

        dispatcher.dispatch(
            DispatcherTestAction(),
            result: Result(value: DispatcherTestModel(name: "test")))

        XCTAssertEqual(results.count, 3)
        XCTAssertEqual(results[0], "test3")
        XCTAssertEqual(results[1], "test2")
        XCTAssertEqual(results[2], "test1")
    }
}
