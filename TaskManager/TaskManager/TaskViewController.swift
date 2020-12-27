//
//  TaskViewController.swift
//  TaskManager
//
//  Created by Kat Berge on 12/4/20.
//

import UIKit

class TaskViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var task: Task!
    
    // variable for editing step contents
    var currStep: Step?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var titleTextView: UITextView!
    @IBOutlet var blurView: UIVisualEffectView!
    @IBOutlet var stepPopUpView: UIView!
    @IBOutlet var stepPopUpTitle: UILabel!
    @IBOutlet var stepTextView: UITextView!
    
    @IBAction func showStepView(_ sender: Any) {
        // set title to show user is creating a new step
        stepPopUpTitle.text = "New Step"
        
        // clear previous entry (if it was there) and add starting text of "Your new step..."
        stepTextView.text = "Your new step..."
        
        animateIn(view: blurView)
        animateIn(view: stepPopUpView)
    }
    
    @IBAction func stepViewDone(_ sender: Any) {
        // if stepPopUpTitle says new step, add step
        if stepPopUpTitle.text == "New Step" {
            TaskManager.main.addStep(taskID: task.id, contents: stepTextView.text)
            reload()
        }
        // else stepPopUp is in edit mode
        else {
            // identify current step and update its contents
            currStep!.contents = stepTextView.text
            TaskManager.main.saveStep(taskID: task.id, step: currStep!)
            reload()
        }
        
        animateOut(view: stepPopUpView)
        animateOut(view: blurView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        titleTextView.text = task.title
        
        // sets blur view to cover screen
        blurView.bounds = self.view.bounds
        
        // sets popup view width and height to percentages of the screen's size
        stepPopUpView.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width * 0.85, height: self.view.bounds.height * 0.4)
        // round edges of popup window
        stepPopUpView.clipsToBounds = true
        stepPopUpView.layer.cornerRadius = 5
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
            // set title to show user is editing an existing step
            self.stepPopUpTitle.text = "Edit Step"
            
            // set text view text to current steps contents
            self.currStep = self.task.steps[indexPath.row]
            self.stepTextView.text = self.task.steps[indexPath.row].contents
            
            self.animateIn(view: self.blurView)
            self.animateIn(view: self.stepPopUpView)
        })
        
        let delete = UIContextualAction(style: .normal, title: "Delete", handler: {_,_,_ in
            TaskManager.main.deleteStep(taskID: self.task.id, step: self.task.steps[indexPath.row])
            self.reload()
        })
        
        edit.backgroundColor = .systemGreen
        delete.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
    
    func reload() {
        task.steps = TaskManager.main.getSteps(taskID: task.id)
        self.tableView.reloadData()
    }
    
    // animate in and out functions for a UIView
    // from CodeMorning (link: www.youtube.com/watch?v=gLTDY8Qj6EM&t=67s)
    func animateIn(view: UIView) {
        self.view.addSubview(view)
        
        // start view scaled at 120% and with alpha/opacity = 0
        view.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        view.alpha = 0
        view.center = self.view.center
        
        UIView.animate(withDuration: 0.3, animations: {
            view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            view.alpha = 1
        })
    }
    
    func animateOut(view: UIView) {
        UIView.animate(withDuration: 0.3, animations: {
            view.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            view.alpha = 0
        }, completion: { _ in
            view.removeFromSuperview()
        })
    }
}
