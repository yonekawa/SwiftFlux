import UIKit
import SwiftFlux

class TodoListViewController: UITableViewController {
    let todoStore = TodoStore()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.todoStore.subscribe { () in
            self.tableView.reloadData()
        }

        ActionCreator.invoke(TodoAction.Fetch())
    }

    @IBAction func createTodo() {
        ActionCreator.invoke(TodoAction.Create(title: "New ToDo"))
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.todoStore.todos.count
    }

    override func tableView(
        tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("TodoCell") as UITableViewCell!
        cell.textLabel!.text = self.todoStore.todos[indexPath.row].title
        return cell
    }

    override func tableView(
        tableView: UITableView,
        commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath) {

        ActionCreator.invoke(TodoAction.Delete(index: indexPath.row))
    }
}
