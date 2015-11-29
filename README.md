# SwiftFlux

[![Travis CI](https://travis-ci.org/yonekawa/SwiftFlux.svg?branch=master)](https://travis-ci.org/yonekawa/SwiftFlux)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Cocoapods](https://img.shields.io/cocoapods/v/SwiftFlux.svg)](https://cocoapods.org/pods/SwiftFlux)

SwiftFlux is an implementation of [Facebook's Flux architecure](https://facebook.github.io/flux/) for Swift.  
It provides concept of "one-way data flow" with **type-safe** modules by Swift language.

- Type of an action's payload is inferred from the type of its action.
- A result of an action is represented by [Result](https://github.com/antitypical/Result), which is also known as Either.
- EventEmitter supports to fire event of Store changed.

# Requirements

- Swift 2.0 or later
- iOS 8.0 or later
- Mac OS 10.9 or later
- watch OS 2.0 or later

## Installation

#### [Carthage](https://github.com/Carthage/Carthage)

- Insert `github "yonekawa/SwiftFlux"` to your Cartfile.
- Run `carthage update`.
- Link your app with `SwiftFlux.framework`, `Result.framework`, in Carthage/Build

#### [Cocoapods](https://cocoapods.org/)

- Insert `pod "SwiftFlux"` to your Podfile:
- Run `pod install`.

## Usage

### Step 1: Define Action

- Assign type that represents a result object to Payload `typealiase`.
- Define `invoke` to dispatching action to stores.
- You can call api request here (you can use asynchronous request).

```swift
struct TodoAction {
    struct Create : Action {
        typealias Payload = Todo
        func invoke(dispatcher: Dispatcher) {
            let todo = Todo(title: "New ToDo")
            dispatcher.dispatch(self, result: Result(value: todo))
        }
    }
}
```

### Step 2: Define Store and register action to dispatch

- Define event enum and assign type to Event `typealiase`.
- Define `EventEmitter` instance with generic type.
- Register any subscribe action callback to dispatcher.
- Unbox action result value by Either in callback.

```swift
class TodoStore : Store {
    enum TodoEvent {
        case Created
    }
    typealias Event = TodoEvent

    let eventEmitter = EventEmitter<TodoStore>()

    private var todos = [Todo]()
    var list: Array<Todo> {
        get {
            return todos;
        }
    }

    init() {
        ActionCreator.dispatcher.register(TodoAction.List.self) { (result) in
            switch result {
            case .Success(let value):
                self.todos.append(value)
                self.eventEmitter.emit(.Created)
            case .Failure(let error):
                NSLog("error \(error)")
                break;
            }
        }
    }
}
```

### Step 3: Listen store's event at View

- Listen store's event by `EventEmitter` created at Step2.
- Get result from store's public interface.

```swift
let todoStore = TodoStore()
todoStore.eventEmitter.listen(.Created) { () -> Void in
    for todo in todoStore.list {
        plintln(todo.title)
    }
}
```

### Step 4: Create and invoke Action by ActionCreator

```swift
ActionCreator.invoke(TodoAction.Create())
```

## Advanced

### Destroy callbacks

Store registerer handler to Action by Dispatcher.
Dispatcher has handler reference in collection.
You need to release handler reference when store instance released.

```swift
class TodoStore {
    private var dispatchIdentifiers: Array<String> = []
    init() {
        dispatchIdentifiers.append(
            ActionCreator.dispatcher.register(TodoAction.self) { (result) -> Void in
              ...
            }
        )
    }

    func unregsiter() {
        for identifier in dispatchIdentifiers {
            ActionCreator.dispatcher.unregister(identifier)
        }
    }
}

class TodoViewController {
  let store = TodoStore()
  deinit {
      store.unregister()
  }
}
```

`StoreBase` contains register/unregister utility.
You can use these methods when override it to your own Store class.

### Replace to your own Dispatcher

Override dispatcher getter of `ActionCreator`, you can replace app dispatcher.

```swift
class MyActionCreator: ActionCreator {
  static let ownDispatcher = YourOwnDispatcher()
  class MyActionCreator: ActionCreator {
    override class var dispatcher: Dispatcher {
        get {
            return ownDispatcher
        }
    }
}
class YourOwnDispatcher: Dispatcher {
    func dispatch<T: Action>(action: T, result: Result<T.Payload, T.Error>) {
        ...
    }
    func register<T: Action>(type: T.Type, handler: (Result<T.Payload, T.Error>) -> Void) -> String {
        ...
    }

    func unregister(identifier: String) {
        ...
    }
    func waitFor<T: Action>(identifiers: Array<String>, type: T.Type, result: Result<T.Payload, T.Error>) {
        ...
    }
}
```

## Use your own ErrorType instead of NSError

You can assign your own `ErrorType` with `typealias` on your `Action`.

```swift
struct TodoAction: ErrorType {
    enum TodoError {
        case CreateError
    }
    struct Create : Action {
        typealias Payload = Todo
        typealias Error = TodoError
        func invoke(dispatcher: Dispatcher) {
            let error = TodoError.CreateError
            dispatcher.dispatch(self, result: Result(error: error))
        }
    }
}
```

## Flux Utils

SwiftFlux contains basic `Store` implementation utilities like as [flux-utils](https://facebook.github.io/flux/docs/flux-utils.html).

### StoreBase

`StoreBase` provides basic store implementation.
For example, register/unregister callback of `Action`, `eventEmitter` property, etc.

```swift
class CalculateStore: StoreBase {
    private var internalNumber = 0
    var number: Int {
        return internalNumber
    }

    override init() {
        super.init()

        self.register(CalculateActions.Plus.self) { (result) in
            switch result {
            case .Success(let value):
                self.internalNumber += value
                self.eventEmitter.emit(.Changed)
            default:
                break
            }
        }

        self.register(CalculateActions.Minus.self) { (result) in
            switch result {
            case .Success(let value):
                self.internalNumber -= value
                self.eventEmitter.emit(.Changed)
            default:
                break
            }
        }
    }
}
```

### ReduceStore

`ReduceStore` provides simply implementation to reduce the current state by reducer.
Reducer receives the current state and Action's result. And reducer returns new state reduced.
Reducer should be pure and have no side-effects.
`ReduceStore` extends `StoreBase`.

```swift
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
```

## License

SwiftFlux is released under the [MIT License](https://github.com/yonekawa/SwiftFlux/blob/master/LICENSE).
