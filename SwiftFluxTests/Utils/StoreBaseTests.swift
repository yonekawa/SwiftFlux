import Foundation
import XCTest
import SwiftFlux

class StoreBaseTests: XCTestCase {

    struct CalculateActions {
        struct Plus: Action {
            typealias Payload = Int
            let number: Int
            func invoke(dispatcher: Dispatcher) {
                dispatcher.dispatch(self, result: Result(value: number))
            }
        }
        struct Minus: Action {
            typealias Payload = Int
            let number: Int
            func invoke(dispatcher: Dispatcher) {
                dispatcher.dispatch(self, result: Result(value: number))
            }
        }
    }
    
    class CalculateStore: StoreBase {
        private(set) var number: Int = 0

        override init() {
            super.init()

            self.register(CalculateActions.Plus.self) { (result) in
                switch result {
                case .Success(let value):
                    self.number += value
                    self.emitChange()
                default:
                    break
                }
            }
            
            self.register(CalculateActions.Minus.self) { (result) in
                switch result {
                case .Success(let value):
                    self.number -= value
                    self.emitChange()
                default:
                    break
                }
            }
        }
    }

    let store = CalculateStore()
    var results = [Int]()

    override func setUp() {
        results = []
        self.store.subscribe { () in
            self.results.append(self.store.number)
        }
    }

    override func tearDown() {
        store.unregister()
    }

    func testShouldCalculateStateWithNumber() {
        ActionCreator.invoke(CalculateActions.Plus(number: 3))
        ActionCreator.invoke(CalculateActions.Plus(number: 3))
        ActionCreator.invoke(CalculateActions.Minus(number: 2))
        ActionCreator.invoke(CalculateActions.Minus(number: 1))

        XCTAssertEqual(results.count, 4)
        XCTAssertEqual(results[0], 3)
        XCTAssertEqual(results[1], 6)
        XCTAssertEqual(results[2], 4)
        XCTAssertEqual(results[3], 3)
    }
}
