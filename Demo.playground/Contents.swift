//: Playground - noun: a place where people can play

import XCPlayground
import UIKit
import Box
import Result
import SwiftFlux

XCPSetExecutionShouldContinueIndefinitely()

struct Todo {
    let title: String
}

//: Step 1: Define action
class TodoAction {
    class List : Action {
        typealias Payload = [Todo]
        func invoke() {
            let todos = [
                Todo(title: "List ToDo 1"),
                Todo(title: "List ToDo 2"),
                Todo(title: "List ToDo 3")
            ]
            Dispatcher.dispatch(self, result: Result(value: todos))
        }
    }
}

//: Step 2: Define Store
class TodoStore : Store {
    static let instance = TodoStore()
    
    enum TodoEvent {
        case List
    }
    typealias Event = TodoEvent
    
    private var todos = [Todo]()
    var list: Array<Todo> {
        get {
            return todos;
        }
    }
    
    init() {
        Dispatcher.register(TodoAction.List()) { (result) -> Void in
            switch result {
            case .Success(let box):
                self.todos = box.value
                EventEmitter.emit(self, event: TodoEvent.List)
            case .Failure(let box):
                break;
            }
        }
    }
}

//: Step 3: Listen store's event
EventEmitter.listen(TodoStore.instance, event: TodoStore.Event.List) { () -> Void in
    for todo in TodoStore.instance.list {
        plintln(todo.title)
    }
}

//: Step 4: Create and invoke Action
TodoAction.List().invoke()
