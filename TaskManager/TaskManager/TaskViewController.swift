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
    @IBOutlet var titleLabel: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        titleLabel.text = task.title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return task.steps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StepCell", for: indexPath)
        cell.textLabel?.text = task.steps[indexPath.row].contents
        return cell
    }
}
