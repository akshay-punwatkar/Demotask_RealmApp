import RealmSwift

let realm = try! Realm()

class StorageManager {
    
   static let shared = StorageManager()
    
  // MARK: - Task Lists
   func save(_ taskList: TaskList) {
        try! realm.write {
            realm.add(taskList)
        }
    }
    
     func deleteList(_ taskLists: TaskList) {
        try! realm.write {
            let tasks = taskLists.tasks
            realm.delete(tasks)
            realm.delete(taskLists)
        }
    }
        
    func editList(_ taskList: TaskList, newValue: String) {
        try! realm.write {
            taskList.name = newValue
            }
        }
    
    func makeAllDone(_ taskLists: TaskList) {
        try! realm.write {
            taskLists.tasks.setValue(true, forKey: "completed")
        }
    }
    
    // MARK: - Tasks
     func saveTask(_ tasks: TaskList, task: Task) {
        try! realm.write {
            tasks.tasks.append(task)
            
        }
    }
    
    func deleteTask(_ task: Task) {
        try! realm.write {
            realm.delete(task)
        }
    }
    
    func editTask(_ task: Task, newTask: String, newNote: String) {
        try! realm.write {
            task.name = newTask
            task.note = newNote
        }
    }
    
    func makeAllDone(_ task: Task) {
        try! realm.write {
            task.completed.toggle()
        }
    }
}
