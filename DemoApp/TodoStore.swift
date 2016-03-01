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
    private(set) var todos = [Todo]()

    init() {
        ActionCreator.dispatcher.register(TodoAction.Fetch.self) { (result) in
            switch result {
            case .Success(let box):
                self.todos = box
                self.emitChange()
            case .Failure(_):
                break;
            }
        }

        ActionCreator.dispatcher.register(TodoAction.Create.self) { (result) in
            switch result {
            case .Success(let box):
                self.todos.insert(box, atIndex: 0)
                self.emitChange()
            case .Failure(_):
                break;
            }
        }

        ActionCreator.dispatcher.register(TodoAction.Delete.self) { (result) in
            switch result {
            case .Success(let box):
                self.todos.removeAtIndex(box)
                self.emitChange()
            case .Failure(_):
                break;
            }
        }
    }
}