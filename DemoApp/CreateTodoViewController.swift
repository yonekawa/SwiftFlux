import UIKit
import SwiftFlux

class CreateTodoViewController: UITableViewController {
    @IBOutlet weak var titleTextField: UITextField?

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        titleTextField?.becomeFirstResponder()
    }
    
    @IBAction func createTodo() {
        guard let title = titleTextField?.text else { return }
        guard title.characters.count > 0 else { return }

        ActionCreator.invoke(TodoAction.Create(title: title))
        self.dismiss()
    }

    @IBAction func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
