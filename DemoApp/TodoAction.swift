//
//  TodoAction.swift
//  SwiftFlux
//
//  Created by Kenichi Yonekawa on 8/1/15.
//  Copyright (c) 2015 mog2dev. All rights reserved.
//

import Foundation
import SwiftFlux
import Result

struct TodoAction {
    struct Fetch: Action {
        typealias Payload = [Todo]
        func invoke(dispatcher: Dispatcher) {
            let todos = [
                Todo(title: "ToDo 1"),
                Todo(title: "ToDo 2"),
                Todo(title: "ToDo 3")
            ]
            dispatcher.dispatch(self, result: Result(value: todos))
        }
    }

    struct Create: Action {
        typealias Payload = Todo
        let title: String

        func invoke(dispatcher: Dispatcher) {
            dispatcher.dispatch(self, result: Result(value: Todo(title: title)))
        }
    }

    struct Delete: Action {
        typealias Payload = Int
        let index: Int
        
        func invoke(dispatcher: Dispatcher) {
            dispatcher.dispatch(self, result: Result(value: index))
        }
    }
}
