import XCTest
@testable import SwiftFlux

class ActionCreatorTests: XCTestCase {

    struct ActionCreatorTestModel {
        let name: String
    }

    struct ActionCreatorTestAction: Action {
        typealias Payload = ActionCreatorTestModel
        #if swift(>=3)
            func invoke(_ dispatcher: Dispatcher) {
                dispatcher.dispatch(self, result: Result(value: ActionCreatorTestModel(name: "test")))
            }
        #else
            func invoke(dispatcher: Dispatcher) {
                dispatcher.dispatch(self, result: Result(value: ActionCreatorTestModel(name: "test")))
            }
        #endif
    }

    struct ActionCreatorDefaultErrorAction: Action {
        typealias Payload = ActionCreatorTestModel
        #if swift(>=3)
            func invoke(_ dispatcher: Dispatcher) {
                dispatcher.dispatch(self, result: Result(error: NSError(domain: "TEST00000", code: -1, userInfo: [:])))
            }
        #else
            func invoke(dispatcher: Dispatcher) {
                dispatcher.dispatch(self, result: Result(error: NSError(domain: "TEST00000", code: -1, userInfo: [:])))
            }
        #endif
    }

    enum ActionError: ErrorProtocol {
        case UnexpectedError(NSError)
    }

    struct ActionCreatorErrorAction: Action {
        typealias Payload = ActionCreatorTestModel
        typealias Error = ActionError

        #if swift(>=3)
            func invoke(_ dispatcher: Dispatcher) {
                let error = ActionError.UnexpectedError(
                    NSError(domain: "TEST00000", code: -1, userInfo: [:])
                )
                dispatcher.dispatch(self, result: Result(error: error))
            }
        #else
            func invoke(dispatcher: Dispatcher) {
                let error = ActionError.UnexpectedError(
                    NSError(domain: "TEST00000", code: -1, userInfo: [:])
                )
                dispatcher.dispatch(self, result: Result(error: error))
            }
        #endif
    }

    var results = [String]()
    var fails = [String]()
    var callbacks = [String]()

    override func setUp() {
        results = []
        fails = []
        callbacks = []
        
        let id1 = ActionCreator.dispatcher.register(ActionCreatorTestAction.self) { (result) in
            switch result {
            case .Success(let box):
                self.results.append("\(box.name)1")
            case .Failure(_):
                self.fails.append("fail1")
            }
        }
        let id2 = ActionCreator.dispatcher.register(ActionCreatorErrorAction.self) { (result) in
            switch result {
            case .Success(let box):
                self.results.append("\(box.name)2")
            case .Failure(let error):
                self.fails.append("fail2 \(error.dynamicType)")
            }
        }
        let id3 = ActionCreator.dispatcher.register(ActionCreatorDefaultErrorAction.self) { (result) in
            switch result {
            case .Success(let box):
                self.results.append("\(box.name)3")
            case .Failure(let error):
                self.fails.append("fail3 \(error.dynamicType)")
            }
        }
        callbacks.append(id1)
        callbacks.append(id2)
        callbacks.append(id3)
    }

    override func tearDown() {
        for id in callbacks {
            ActionCreator.dispatcher.unregister(id)
        }
    }
    
    func testWhenActionSucceeded() {
        // it should dispatch to registered callback handlers
        let action = ActionCreatorTestAction()
        ActionCreator.invoke(action)

        XCTAssertEqual(results.count, 1)
        XCTAssert(fails.isEmpty)
        #if swift(>=3)
            XCTAssertNotNil(results.index(of: "test1"))
        #else
            XCTAssertNotNil(results.indexOf("test1"))
        #endif
    }

    func testWhenActionFailedWithErrorType() {
        // it should dispatch to registered callback handlers
        let action = ActionCreatorErrorAction()
        ActionCreator.invoke(action)
        
        XCTAssertEqual(fails.count, 1)
        XCTAssert(results.isEmpty)
        #if swift(>=3)
            XCTAssertNotNil(fails.index(of: "fail2 ActionError"))
        #else
            XCTAssertNotNil(fails.indexOf("fail2 ActionError"))
        #endif
    }

    func testWhenActionFailed() {
        // it should dispatch to registered callback handlers
        let action = ActionCreatorDefaultErrorAction()
        ActionCreator.invoke(action)
        
        XCTAssertEqual(fails.count, 1)
        XCTAssert(results.isEmpty)
        #if swift(>=3)
            XCTAssertNotNil(fails.index(of: "fail3 NSError"))
        #else
            XCTAssertNotNil(fails.indexOf("fail3 NSError"))
        #endif
    }
}
