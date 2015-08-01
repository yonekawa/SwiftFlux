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
    class List : Action {
        typealias Payload = [Todo]
        func invoke() {
            let todos = [Todo(title: "List ToDo 1"), Todo(title: "List ToDo 2"), Todo(title: "List ToDo 3")]
            Dispatcher.dispatch(self, result: Result(value: todos))
        }
    }

    class Create : Action {
        typealias Payload = Todo

        private var title: String = ""

        init() {}
        init(title: String) {
            self.title = title
        }
        
        func invoke() {
            Dispatcher.dispatch(self, result: Result(value: Todo(title: self.title)))
        }
    }
}
