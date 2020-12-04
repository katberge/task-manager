//
//  Task.swift
//  TaskManager
//
//  Created by Kat Berge on 11/23/20.
//

import Foundation
import SQLite3

struct Task {
    let title: String
    let steps: [Step]
}

struct Step {
    let contents: String
    var completed: Bool
}

class TaskManager {
    var database: OpaquePointer?
    
    func setUpDatabase() {
        do  {
            let databaseURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("tasks.sqlite3")
            
            if sqlite3_open(databaseURL.path, &database) == SQLITE_OK {
                if sqlite3_exec(database, "CREATE TABLE IF NOT EXIST tasks (title TEXT)", nil, nil, nil) != SQLITE_OK {
                    print("Error creating tasks table")
                }
                if sqlite3_exec(database, "CREATE TABLE IF NOT EXIST steps (taskid INT, contents TEXT, completed INT)", nil, nil, nil) != SQLITE_OK {
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
}
