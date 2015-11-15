//
//  TodoStore.swift
//  SwiftFlux
//
//  Created by Kenichi Yonekawa on 8/1/15.
//  Copyright (c) 2015 mog2dev. All rights reserved.
//

import Foundation
import SwiftFlux
import Result

class TodoStore : Store {
    enum TodoEvent {
        case List
        case Created
    }
    typealias Event = TodoEvent

    let eventEmitter = EventEmitter<TodoStore>()

    private var todos = [Todo]()
    var list: Array<Todo> {
        return todos;
    }

    init() {
        ActionCreator.dispatcher.register(TodoAction.List.self) { (result) -> Void in
            switch result {
            case .Success(let box):
                self.todos = box
                self.eventEmitter.emit(TodoEvent.List)
            case .Failure(_):
                break;
            }
        }

        ActionCreator.dispatcher.register(TodoAction.Create.self) { (result) -> Void in
            switch result {
            case .Success(let box):
                self.todos.insert(box, atIndex: 0)
                self.eventEmitter.emit(TodoEvent.Created)
            case .Failure(_):
                break;
            }
        }
    }
}