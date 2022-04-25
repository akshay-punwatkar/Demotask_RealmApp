import UIKit
import RealmSwift

class TasksListTableViewController: UITableViewController {

    var taskLists: Results<TaskList>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskLists = realm.objects(TaskList.self)
        navigationItem.leftBarButtonItem = editButtonItem
        tableView.tableFooterView = UIView(frame: CGRect.zero)
                
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - Actions
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        alerForAddAndUpdateList()
    }
    @IBAction func sortingSegment(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0 {
          taskLists = taskLists.sorted(byKeyPath: "name")
        } else {
          taskLists = taskLists.sorted(byKeyPath: "date")
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return taskLists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let taskList = taskLists[indexPath.row]
        
        cell.textLabel?.text = taskList.name
        cell.detailTextLabel?.text = "\(taskList.tasks.count)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let currentList = taskLists[indexPath.row]
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") {_,_ in
            StorageManager.shared.deleteList(currentList)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
        }
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (_, _) in
            self.alerForAddAndUpdateList(currentList) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        
        let doneAction = UITableViewRowAction(style: .normal, title: "Done") { (_, _) in
            StorageManager.shared.makeAllDone(currentList)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        editAction.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        doneAction.backgroundColor = #colorLiteral(red: 0.08333682269, green: 0.6889733672, blue: 0.9759301543, alpha: 1)
        
        return [deleteAction,editAction,doneAction]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let taskList = taskLists[indexPath.row]
            let taskVC = segue.destination as! TasksTableViewController
            taskVC.currentList = taskList
        }
    
    }

}

// MARK: - Alert Controller
extension TasksListTableViewController {
    
    private func alerForAddAndUpdateList(_ taskList: TaskList? = nil, completion: (() -> Void)? = nil) {
        
        var title = "Create Task List"
        var doneButton = "Create"
        
        if taskList != nil {
            title = "Edit Task List"
            doneButton = "Update"
        }
        
        let alert = UIAlertController(title: title, message: "Please insert new value", preferredStyle: .alert)
        
        var alertTextField: UITextField!
        
        let saveAction = UIAlertAction(title: doneButton, style: .default) { _ in
            
            guard let text = alertTextField.text , !text.isEmpty else { return }
            
            if let listName = taskList {
                
                StorageManager.shared.editList(listName, newValue: text)
                
                if completion != nil { completion!()}
                
            } else {
                let taskList = TaskList()
                taskList.name = text
                
                StorageManager.shared.save(taskList)
                
                self.tableView.insertRows(at: [IndexPath(row: self.taskLists.count - 1, section: 0)], with: .automatic)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        alert.addTextField { textField in
            alertTextField = textField
            alertTextField.placeholder = "List Name"
        }
        
        if let taskList = taskList {
            alertTextField.text = taskList.name
        }
        
        present(alert, animated: true)
    }

}
