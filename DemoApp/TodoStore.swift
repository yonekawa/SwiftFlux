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
import Box

class TodoStore : Store {
    static let instance = TodoStore()

    enum TodoEvent {
        case List
        case Created
    }
    typealias Event = TodoEvent
    
    private var todos = [Todo]()
    var list: Array<Todo> {
        get {
            return todos;
        }
    }

    init() {
        Dispatcher.register(TodoAction.List.self) { (result) -> Void in
            switch result {
            case .Success(let box):
                self.todos = box.value
                EventEmitter.emit(self, event: TodoEvent.List)
            case .Failure(let box):
                break;
            }
        }

        Dispatcher.register(TodoAction.Create.self) { (result) -> Void in
            switch result {
            case .Success(let box):
                self.todos.insert(box.value, atIndex: 0)
                EventEmitter.emit(self, event: TodoEvent.Created)
            case .Failure(let box):
                break;
            }
        }
    }
}