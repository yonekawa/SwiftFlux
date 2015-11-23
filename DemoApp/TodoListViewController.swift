//
//  TodoListViewController.swift
//  DemoApp
//
//  Created by Kenichi Yonekawa on 8/1/15.
//  Copyright (c) 2015 mog2dev. All rights reserved.
//

import UIKit
import SwiftFlux

class TodoListViewController: UITableViewController {
    let todoStore = TodoStore()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.todoStore.eventEmitter.listen(TodoStore.Event.Fetched) { () in
            self.tableView.reloadData()
        }
        self.todoStore.eventEmitter.listen(TodoStore.Event.Created) { () in
            self.tableView.reloadData()
        }
        self.todoStore.eventEmitter.listen(TodoStore.Event.Deleted) { () in
            self.tableView.reloadData()
        }
        ActionCreator.invoke(TodoAction.Fetch())
    }

    @IBAction func createTodo() {
        ActionCreator.invoke(TodoAction.Create(title: "New ToDo"))
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.todoStore.list.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TodoCell") as UITableViewCell!
        cell.textLabel!.text = self.todoStore.list[indexPath.row].title
        return cell
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        ActionCreator.invoke(TodoAction.Delete(index: indexPath.row))
    }
}

