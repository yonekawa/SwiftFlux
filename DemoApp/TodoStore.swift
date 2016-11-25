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
        
        let _ = ActionCreator.dispatcher.register(type: TodoAction.Fetch.self) { (result) in
            switch result {
            case .success(let box):
                self.todos = box
                self.emitChange()
            case .failure(_):
                break;
            }
        }

        let _ = ActionCreator.dispatcher.register(type: TodoAction.Create.self) { (result) in
            switch result {
            case .success(let box):
                self.todos.insert(box, at: 0)
                self.emitChange()
            case .failure(_):
                break;
            }
        }

        let _ = ActionCreator.dispatcher.register(type: TodoAction.Delete.self) { (result) in
            switch result {
            case .success(let box):
                self.todos.remove(at: box)
                self.emitChange()
            case .failure(_):
                break;
            }
        }
    }
}
