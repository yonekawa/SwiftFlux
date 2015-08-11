# SwiftFlux

[![Circle CI](https://img.shields.io/circleci/project/yonekawa/SwiftFlux/master.svg?style=flat)](https://circleci.com/gh/yonekawa/SwiftFlux)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

SwiftFlux is an implementation of [Facebook's Flux architecure](https://facebook.github.io/flux/) for Swift.
It provides concept of "one-way data flow" with **type-safe** modules by Swift language.

- Type of an action payload is inferred from the type of its action.
- A result of an action is represented by [Result](https://github.com/antitypical/Result), which is also known as Either.
- EventEmitter supports to fire event of store changed.

# Requirements

- Swift 1.2 (We has a plan of update to Swift 2)
- iOS 8.0 or later
- Mac OS 10.9 or later

## Installation

[Carthage](https://github.com/Carthage/Carthage)

- Insert github "yonekawa/SwiftFlux" to your Cartfile.
- Run carthage update.
- Link your app with SwiftFlux.framework, Result.framework, Box.framework in Carthage/Build

## Usage

### Step 1: Define Action

- Assign type that represents a result object to Payload `typealiase`.
- Define `invoke` to dispatching action to stores.
- You can call api request here (you can use asynchronous request).

```swift
class TodoAction {
    class Create : Action {
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

    var todos = [Todo]()
    var list: Array<Todo> {
        get {
            return todos;
        }
    }

    init() {
        ActionCreator.dispatcher.register(TodoAction.List.self) { (result) -> Void in
            switch result {
            case .Success(let box):
                self.todo = box.value
                self.eventEmitter.emit(TodoEvent.Created)
            case .Failure(let box):
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
todoStore.eventEmitter.listen(TodoStore.Event.List) { () -> Void in
    for todo in todoStore.list {
        plintln(todo.title)
    }
}
```

### Step 4: Create and invoke Action by ActionCreator

```swift
ActionCreator.invoke(TodoAction.List())
```

## Advanced

### Destroy callbacks

Store registerer handler to Action by Dispatcher.
Dispatcher has handler reference in collection.
You need to release when store instance released.

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

    deinit {
        for identifier in dispatchIdentifiers {
            ActionCreator.dispatcher.unregister(identifier)
        }
    }
```

### Replace to your own Dispatcher

Override dispatcher getter of `ActionCreator`, you can replace app dispatcher.

```swift
class MyActionCreator: ActionCreator {
  class MyActionCreator: ActionCreator {
    override class var dispatcher: Dispatcher {
        get {
            return YourOwnDispatcher()
        }
    }
}
class YourOwnDispatcher: Dispatcher {
    func dispatch<T: Action>(action: T, result: Result<T.Payload, NSError>) {
        ...
    }
    func register<T: Action>(type: T.Type, handler: (Result<T.Payload, NSError>) -> Void) -> String {
        ...
    }

    func unregister(identifier: String) {
        ...
    }
    func waitFor<T: Action>(identifiers: Array<String>, type: T.Type, result: Result<T.Payload, NSError>) {
        ...
    }
}
```

## License

SwiftFlux is released under the [MIT License](https://github.com/yonekawa/SwiftFlux/blob/master/LICENSE).
