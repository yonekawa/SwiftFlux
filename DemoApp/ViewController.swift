//
//  ViewController.swift
//  DemoApp
//
//  Created by Kenichi Yonekawa on 8/1/15.
//  Copyright (c) 2015 mog2dev. All rights reserved.
//

import UIKit
import SwiftFlux

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        EventEmitter.listen(TodoStore.instance, event: TodoStore.Event.List) { () -> Void in
            self.tableView.reloadData()
        }
        EventEmitter.listen(TodoStore.instance, event: TodoStore.Event.Created) { () -> Void in
            self.tableView.reloadData()
        }
        TodoAction.List().invoke()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TodoStore.instance.list.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("TodoCell") as! UITableViewCell
        cell.textLabel!.text = TodoStore.instance.list[indexPath.row].title
        return cell
    }

    @IBAction func createTodo() {
        TodoAction.Create(title: "New ToDo").invoke()
    }
}

