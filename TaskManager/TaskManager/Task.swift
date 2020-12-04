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
    let title: String
    let steps: [Step]
}

struct Step {
    let contents: String
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
}
