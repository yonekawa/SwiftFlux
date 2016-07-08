import XCTest
import SwiftFlux

class ReduceStoreTests: XCTestCase {

    struct CalculateActions {
        struct Plus: Action {
            typealias Payload = Int
            let number: Int

            #if swift(>=3)
                func invoke(_ dispatcher: Dispatcher) {
                    dispatcher.dispatch(self, result: Result(value: number))
                }
            #else
                func invoke(dispatcher: Dispatcher) {
                    dispatcher.dispatch(self, result: Result(value: number))
                }
            #endif
        }
        struct Minus: Action {
            typealias Payload = Int
            let number: Int

            #if swift(>=3)
                func invoke(_ dispatcher: Dispatcher) {
                    dispatcher.dispatch(self, result: Result(value: number))
                }
            #else
                func invoke(dispatcher: Dispatcher) {
                    dispatcher.dispatch(self, result: Result(value: number))
                }
            #endif
        }
    }

    class CalculateStore: ReduceStore<Int> {
        init() {
            super.init(initialState: 0)

            self.reduce(CalculateActions.Plus.self) { (state, result) -> Int in
                switch result {
                case .Success(let number): return state + number
                default: return state
                }
            }

            self.reduce(CalculateActions.Minus.self) { (state, result) -> Int in
                switch result {
                case .Success(let number): return state - number
                default: return state
                }
            }
        }
    }

    let store = CalculateStore()
    var results = [Int]()

    override func setUp() {
        results = []
        store.subscribe { () -> () in
            self.results.append(self.store.state)
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
