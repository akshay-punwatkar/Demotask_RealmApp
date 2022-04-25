import UIKit
import RealmSwift

class TasksTableViewController: UITableViewController {

    var currentList: TaskList!
    
   private var currentTasks: Results<Task>!
   private var completedTasks: Results<Task>!
   private var isEditingMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = currentList.name
        filteringTasks()
    }
    
    // MARK: - Actions
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        isEditing.toggle()
        tableView.setEditing(isEditing, animated: true)
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        alertForAddAndUpdateList()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Current Tasks" : "Completed Tasks"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? currentTasks.count : completedTasks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        var task: Task!
        task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        
        cell.textLabel?.text = task.name
        cell.detailTextLabel?.text = task.note
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        var task: Task!
        
        task = indexPath.section == 0 ? currentTasks[indexPath.row] : completedTasks[indexPath.row]
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (_, _) in
            StorageManager.shared.deleteTask(task)
            self.filteringTasks()
        }
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (_,_) in
            self.alertForAddAndUpdateList(task)
            self.filteringTasks()
        }
        
        let doneAction = UITableViewRowAction(style: .normal, title: "Done") { (_, _) in
            StorageManager.shared.makeAllDone(task)
            self.filteringTasks()
        }
        
        editAction.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        doneAction.backgroundColor = #colorLiteral(red: 0.08333682269, green: 0.6889733672, blue: 0.9759301543, alpha: 1)
        
        return [deleteAction,editAction,doneAction]
    }
    
    private func filteringTasks() {
        
        currentTasks = currentList.tasks.filter("completed = false")
        completedTasks = currentList.tasks.filter("completed = true")
        
        tableView.reloadData()
    }
         
}

extension TasksTableViewController {
    
    private func alertForAddAndUpdateList(_ task: Task? = nil, completion: (()-> Void)? = nil) {
           
           var title = "Create new task"
           var doneButton = "Create"
        
           if task != nil {
            title = "Update task"
            doneButton = "Update"
           }
        
           let alert = UIAlertController(title: title, message: "Please insert task value", preferredStyle: .alert)
           var taskTextField: UITextField!
           var noteTextField: UITextField!
           
           let saveAction = UIAlertAction(title: doneButton, style: .default) { _ in
            
           guard let text = taskTextField.text , !text.isEmpty else { return }
            
            if let task = task {
                if let newNote = noteTextField.text , !newNote.isEmpty {
                    StorageManager.shared.editTask(task, newTask: text, newNote: newNote)
                } else {
                    StorageManager.shared.editTask(task, newTask: text, newNote: "")
                }
                self.filteringTasks()
            } else {
                let task = Task()
                    task.name = text
                           
              if let note = noteTextField.text, !note.isEmpty {
                     task.note = note
                }
                           
            StorageManager.shared.saveTask(self.currentList, task: task)
                           
            self.filteringTasks()
                
               }
            
           }
           
           let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
           
           alert.addAction(saveAction)
           alert.addAction(cancelAction)
           
           alert.addTextField { textField in
               taskTextField = textField
               taskTextField.placeholder = "New task"
            
                if let task = task {
                    taskTextField.text = task.name
              }
        }
           
           alert.addTextField { textField in
               noteTextField = textField
               noteTextField.placeholder = "Note"
            
            if let task = task {
                noteTextField.text = task.note
            }
           }
        
           present(alert, animated: true)
       }

}
