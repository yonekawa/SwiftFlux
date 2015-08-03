# SwiftFlux

[![Circle CI](https://img.shields.io/circleci/project/yonekawa/SwiftFlux/master.svg?style=flat)](https://circleci.com/gh/yonekawa/SwiftFlux)
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/yonekawa/SwiftFlux/master/LICENSE)
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
        func invoke() {
            let todo = Todo(title: "New ToDo")
            Dispatcher.dispatch(self, result: Result(value: todo))
        }
    }
}
```

### Step 2: Define Store and register action to dispatch

- Define event enum and assign type to Event `typealiase`.
- Register any subscribe action callback to dispatcher.
- Unbox action result value by Either in callback.

```swift
class TodoStore : Store {
    static let instance = TodoStore()

    enum TodoEvent {
        case Created
    }
    typealias Event = TodoEvent

	var todos = [Todo]()
    var list: Array<Todo> {
        get {
            return todos;
        }
    }

    init() {
        Dispatcher.register(TodoAction.List()) { (result) -> Void in
            switch result {
            case .Success(let box):
                self.todo = box.value
                EventEmitter.emit(self, event: TodoEvent.Created)
            case .Failure(let box):
                break;
            }
        }
    }
}
```

### Step 3: Listen store's event at View

- Listen store's event by `EventEmitter`
- Get result from store's public interface.

```swift
EventEmitter.listen(TodoStore.instance, event: TodoStore.Event.List) { () -> Void in
    for todo in TodoStore.instance.list {
        plintln(todo.title)
    }
}
```

### Step 4: Create and invoke Action from View

```swift
TodoAction.List().invoke()
```

## License

MIT License. See the [LICENSE](https://github.com/yonekawa/SwiftFlux/blob/master/LICENSE) file for details.
