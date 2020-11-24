//
//  TaskListViewController.swift
//  TaskManager
//
//  Created by Kat Berge on 11/23/20.
//

import UIKit

class TaskListViewController: UITableViewController {
    var tasks: [Task] = []

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
        cell.textLabel?.text = tasks[indexPath.row].content
        return cell
    }

}
