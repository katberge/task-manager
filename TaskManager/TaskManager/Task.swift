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
        
        if sqlite3_prepare(database, "INSERT INTO tasks (title) VALUES ('New Task')", -1, &statement, nil) != SQLITE_OK {
            print("Error creating task query")
        }
        else if sqlite3_step(statement) != SQLITE_DONE {
            print("Error making new task")
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
            result.append(Task(id: Int(sqlite3_column_int(statement, 0)), title: String(cString: sqlite3_column_text(statement, 1)), steps: [Step(contents: "New step", completed: 0)]))
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
        
        if sqlite3_prepare(database, "DELETE FROM tasks WHERE rowid = ?", -1, &statement, nil) == SQLITE_OK {
            sqlite3_bind_int(statement, 1, Int32(task.id))
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Error deleting task")
            }
        }
        else {
            print("Error creating delete statement")
        }
        
        sqlite3_finalize(statement)
    }
}
