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

class TodoAction {
    class Fetch: Action {
        typealias Payload = [Todo]
        func invoke(dispatcher: Dispatcher) {
            let todos = [
                Todo(title: "Default ToDo 1"),
                Todo(title: "Default ToDo 2"),
                Todo(title: "Default ToDo 3")
            ]
            dispatcher.dispatch(self, result: Result(value: todos))
        }
    }

    class Create: Action {
        typealias Payload = Todo

        private var title: String = ""
        init(title: String) {
            self.title = title
        }

        func invoke(dispatcher: Dispatcher) {
            dispatcher.dispatch(self, result: Result(value: Todo(title: self.title)))
        }
    }
}
