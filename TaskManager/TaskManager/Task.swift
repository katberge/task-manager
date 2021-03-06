//
//  Task.swift
//  TaskManager
//
//  Created by Kat Berge on 11/23/20.
//

import Foundation
import SQLite3

struct Task {
    let id: Int
    var title: String
    var steps: [Step]
}

struct Step {
    var id: Int
    var contents: String
    var completed: Int
}

class TaskManager {
    var database: OpaquePointer?
    
    // makes taskManager a singleton
    static let main = TaskManager()
    private init() {
    }
    
    func setUpDatabase() {
        if database != nil {
            return
        }
        
        do  {
            let databaseURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("tasks.sqlite3")
            
            if sqlite3_open(databaseURL.path, &database) == SQLITE_OK {
                if sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS tasks (title TEXT)", nil, nil, nil) != SQLITE_OK {
                    print("Error creating tasks table")
                }
                if sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS steps (taskid INT, contents TEXT, completed INT)", nil, nil, nil) != SQLITE_OK {
                    print("Error creating tasks table")
                }
            }
            else {
                print("Error connecting")
            }
        }
        catch let error {
            print(error)
        }
    }
    
    func createNew() {
        setUpDatabase()
        
        var statement: OpaquePointer?
        var stepStatement: OpaquePointer?
        
        if sqlite3_prepare(database, "INSERT INTO tasks (title) VALUES ('New Task')", -1, &statement, nil) != SQLITE_OK {
            print("Error creating task query")
        }
        else if sqlite3_step(statement) != SQLITE_DONE {
            print("Error making new task")
        }
        
        // set up one initial step
        if sqlite3_prepare(database, "INSERT INTO steps (taskid, contents, completed) VALUES (?, 'New Step', 0)", -1, &stepStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(stepStatement, 1, Int32(sqlite3_last_insert_rowid(database)))
        }
        else {
            print("Error creating step query")
        }
        
        if sqlite3_step(stepStatement) != SQLITE_DONE {
            print("Error making new step")
        }
    }
    
    func getAllTasks() -> [Task] {
        setUpDatabase()
        
        var result: [Task] = []
        var statement: OpaquePointer?
        
        if sqlite3_prepare(database, "SELECT rowid, title FROM tasks", -1, &statement, nil) != SQLITE_OK {
            print("Error creating select query")
            return []
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            let currRowID = Int(sqlite3_column_int(statement, 0))
            var stepResults: [Step] = []
            var stepStatement: OpaquePointer?
            
            // get steps to current task
            if sqlite3_prepare(database, "SELECT rowid, contents, completed FROM steps WHERE taskid = ?", -1, &stepStatement, nil) != SQLITE_OK {
                print("Error creating select query")
                return []
            }
            sqlite3_bind_int(stepStatement, 1, Int32(currRowID))
            while sqlite3_step(stepStatement) == SQLITE_ROW {
                stepResults.append(Step(id: Int(sqlite3_column_int(stepStatement, 0)), contents: String(cString: sqlite3_column_text(stepStatement, 1)), completed: Int(sqlite3_column_int(stepStatement, 2))))
            }
            sqlite3_finalize(stepStatement)
            
            result.append(
                Task(id: currRowID,
                     title: String(cString: sqlite3_column_text(statement, 1)),
                     steps: stepResults)
            )
        }
        
        sqlite3_finalize(statement)
        
        return result
    }
    
    func saveTaskTitle(task: Task) {
        setUpDatabase()
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare(database, "UPDATE tasks SET title = ? WHERE rowid = ?", -1, &statement, nil) != SQLITE_OK {
            print("Error creating save task statement")
            
        }
        
        sqlite3_bind_text(statement, 1, NSString(string: task.title).utf8String, -1, nil)
        sqlite3_bind_int(statement, 2, Int32(task.id))
        
        if sqlite3_step(statement) != SQLITE_DONE {
            print("Error saving task")
        }
        
        sqlite3_finalize(statement)
    }
    
    func deleteTask(task: Task) {
        setUpDatabase()
        
        var statement: OpaquePointer?
        var stepStatement: OpaquePointer?
        let taskID = Int32(task.id)
        
        if sqlite3_prepare(database, "DELETE FROM tasks WHERE rowid = ?", -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, taskID)
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Error deleting task")
            }
        }
        else {
            print("Error creating delete statement")
        }
        sqlite3_finalize(statement)
        
        if sqlite3_prepare(database, "DELETE FROM steps WHERE taskid = ?", -1, &stepStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(stepStatement, 1, taskID)
            if sqlite3_step(stepStatement) != SQLITE_DONE {
                print("Error deleting steps")
            }
        }
        else {
            print("Error creating delete step statement")
        }
        sqlite3_finalize(stepStatement)
    }
    
    func getSteps(taskID: Int) -> [Step] {
        setUpDatabase()
        
        var statement: OpaquePointer?
        var result: [Step] = []
        
        if sqlite3_prepare(database, "SELECT rowid, contents, completed FROM steps WHERE taskid = ?", -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(taskID))
        }
        else {
            print("Error creating select query")
            return result
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            result.append(Step(id: Int(sqlite3_column_int(statement, 0)), contents: String(cString: sqlite3_column_text(statement, 1)), completed: Int(sqlite3_column_int(statement, 2))))
        }
        
        sqlite3_finalize(statement)
        
        return result
    }
    
    func addStep(taskID: Int, contents: String) {
        setUpDatabase()
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare(database, "INSERT INTO steps (taskid, contents, completed) VALUES (?, ?, 0)", -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(taskID))
            
            // if provided contents is an empty string, set contents to "New Step"
            if contents == "" {
                sqlite3_bind_text(statement, 2, "New Step", -1, nil)
            }
            else {
                sqlite3_bind_text(statement, 2, NSString(string: contents).utf8String, -1, nil)
            }
        }
        else {
            print("Error creating new step query")
        }
        
        if sqlite3_step(statement) != SQLITE_DONE {
            print("Error making new step")
        }
    }
    
    func saveStep(step: Step) {
        setUpDatabase()
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare(database, "UPDATE steps SET contents = ? WHERE rowid = ?", -1, &statement, nil) != SQLITE_OK {
            print("Error creating save step statement")
            return
        }
        
        sqlite3_bind_text(statement, 1, NSString(string: step.contents).utf8String, -1, nil)
        sqlite3_bind_int(statement, 2, Int32(step.id))
        
        if sqlite3_step(statement) != SQLITE_DONE {
            print("Error saving step")
            return
        }
        
        sqlite3_finalize(statement)
    }
    
    func deleteStep(step: Step) {
        setUpDatabase()
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare(database, "DELETE FROM steps WHERE rowid = ?", -1, &statement, nil) != SQLITE_OK {
            print("Error creating delete step statement")
            return
        }
        
        sqlite3_bind_int(statement, 1, Int32(step.id))
        
        if sqlite3_step(statement) != SQLITE_DONE {
            print("Error deleting step")
            return
        }
        
        sqlite3_finalize(statement)
    }
    
    func toggleCompleted(step: Step) {
        setUpDatabase()
        
        var statement: OpaquePointer?
        
        if sqlite3_prepare(database, "UPDATE steps SET completed = ? WHERE rowid = ?", -1, &statement, nil) != SQLITE_OK {
            print("Error creating save step statement")
            return
        }
        
        // 0 = false, 1 = true
        if step.completed == 0 {
            sqlite3_bind_int(statement, 1, 1)
        }
        else {
            sqlite3_bind_int(statement, 1, 0)
        }
        
        sqlite3_bind_int(statement, 2, Int32(step.id))
        
        if sqlite3_step(statement) != SQLITE_DONE {
            print("Error saving step")
            return
        }
        
        sqlite3_finalize(statement)
    }
}
