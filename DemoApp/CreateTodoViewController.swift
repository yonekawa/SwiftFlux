//
//  CreateTodoViewController.swift
//  SwiftFlux
//
//  Created by Kenichi Yonekawa on 11/20/15.
//  Copyright © 2015 mog2dev. All rights reserved.
//

import UIKit
import SwiftFlux

class CreateTodoViewController: UITableViewController {
    @IBOutlet weak var titleTextField: UITextField?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        titleTextField?.becomeFirstResponder()
    }
    
    @IBAction func createTodo() {
        guard let title = titleTextField?.text else { return }
        guard title.characters.count > 0 else { return }

        ActionCreator.invoke(action: TodoAction.Create(title: title))
        self.dismiss()
    }

    @IBAction func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
}
