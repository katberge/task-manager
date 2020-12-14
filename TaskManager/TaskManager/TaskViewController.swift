//
//  TaskViewController.swift
//  TaskManager
//
//  Created by Kat Berge on 12/4/20.
//

import UIKit

class TaskViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var task: Task!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var titleTextView: UITextView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        titleTextView.text = task.title
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        task.title = titleTextView.text
        TaskManager.main.saveTaskTitle(task: task)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return task.steps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StepCell", for: indexPath)
        cell.textLabel?.text = task.steps[indexPath.row].contents
        return cell
    }
    
    // adds edit and delete as swipe actions
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .normal, title: "Edit", handler: {_,_,_ in
            // move to edit screen
        })
        
        let delete = UIContextualAction(style: .normal, title: "Delete", handler: {_,_,_ in
            // TaskManager.main.deleteStep(task: self.task.steps[indexPath.row])
        })
        
        edit.backgroundColor = .systemGreen
        delete.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [edit, delete])
    }
}
