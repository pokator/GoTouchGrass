//
//  HomeViewController.swift
//  GoTouchGrass
//
//  Created by Kayla Han on 3/1/24.
//

import UIKit
import CoreLocation
import CoreData
import FirebaseDatabase
import FirebaseAuth
import UserNotifications

let appDelegate = UIApplication.shared.delegate as! AppDelegate
let context = appDelegate.persistentContainer.viewContext

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private lazy var databasePath: DatabaseReference? = {
      guard let uid = Auth.auth().currentUser?.uid else {
        return nil
      }
      let ref = Database.database()
        .reference()
        .child("users/\(uid)/preferences")
      return ref
    }()

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    @IBOutlet weak var tableView: UITableView!
    var checkList = [ChecklistItem]()
    var checkedNum = 0
    
    var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .notDetermined {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound]) {
                    (granted,error) in
                    if granted {
                        print("Notifs set")
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }
        })
        
        guard let databasePath = databasePath else {
            return
        }
        databasePath.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                if let preferences = snapshot.value as? [String: Any] {
                    
                    // Save user prefs to local
                    DispatchQueue.main.async {
                        defaults.set(preferences["prefFood"], forKey: "prefFood")
                        defaults.set(preferences["prefGym"], forKey: "prefGym")
                        defaults.set(preferences["prefParks"], forKey: "prefParks")
                        defaults.set(preferences["prefRec"], forKey: "prefRec")
                        defaults.set(preferences["prefShop"], forKey: "prefShop")
                        defaults.set(preferences["locRadius"], forKey: "locRadius")
                        defaults.set(preferences["totalTime"], forKey: "totalTime")
                        defaults.set(preferences["tasksCompleted"], forKey: "tasksCompleted")
                        defaults.set(preferences["numBreaks"], forKey: "numBreaks")
                        print("Retrieved from database, checking pref food:")
                        print(defaults.value(forKey: "prefFood") as Any)
                        print("Checking loc rad:")
                        print(defaults.value(forKey: "locRadius") as Any)
                    }
                }
            } else {
                print("Preferences not found")
            }
        }
        
        //Ensuring location permissions are setup appropriately
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            let message = "Please enable location permissions for the full functionality of the application."
            let controller = UIAlertController(
                title: "Warning",
                message: message,
                preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            controller.addAction(UIAlertAction(title: "OK", style: .default))
            present(controller, animated: true)
            break
        default:
            break
        }
        
        let loadedTasks = retrieveTasks()
        for task in loadedTasks {
            checkList.insert((ChecklistItem(title: task.value(forKey: "name") as! String)), at: (checkList.count - checkedNum))
        }
        
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkList = []
        checkedNum = 0
        let loadedTasks = retrieveTasks()
        for task in loadedTasks {
            checkList.insert((ChecklistItem(title: task.value(forKey: "name") as! String)), at: (checkList.count - checkedNum))
        }
        tableView.reloadData()
    }
    
    // MARK: - CheckList schenanigans
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = checkList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.isChecked ? .checkmark : .none
        cell.backgroundColor = item.isChecked ? UIColor.lightGray : UIColor.white
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checkList.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = checkList[indexPath.row]
        task.isChecked = !task.isChecked
        checkList.remove(at: indexPath.row)
        
        // if it is checked, go to bottom of list
        if task.isChecked {
            checkedNum += 1
            checkList.append(task)
        } else { // if unchecked, move back to top
            checkedNum -= 1
            checkList.insert(task, at: checkList.count - self.checkedNum)
        }
        
        
        tableView.reloadData()
    }
    
    @IBAction func addTaskPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Add Item", message: "Enter task:", preferredStyle: .alert)
                
        // Add a text field to the alert
        alert.addTextField { textField in
            textField.placeholder = "Enter text"
        }
        
        // Add actions to the alert
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let text = alert.textFields?.first?.text else { return }
            self?.checkList.insert((ChecklistItem(title: text)), at: (self!.checkList.count - self!.checkedNum))
            self?.storeTask(name:text)
            self?.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // Add actions to the alert
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        // Present the alert
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func clearListPressed(_ sender: Any) {
        checkList = []
        checkedNum = 0
        clearCoreData()
        tableView.reloadData()
    }
    
    
    func storeTask(name:String) {
        let task = NSEntityDescription.insertNewObject(forEntityName: "Task", into: context)
        
        task.setValue(name, forKey: "name")

        // commit the changes
        saveContext()
    }
    
    func retrieveTasks() -> [NSManagedObject] {
        // retrieve all objects that meet criteria
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"Task")
        var fetchedResults:[NSManagedObject]? = nil
        
        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
        } catch {
            print("Error occurred while retrieving data")
            abort()
        }
        
        return(fetchedResults)!
    }

    func clearCoreData() {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Task")
        var fetchedResults:[NSManagedObject]
        
        do {
            try fetchedResults = context.fetch(request) as! [NSManagedObject]
            
            if fetchedResults.count > 0 {
                // delete it
                
                for result in fetchedResults {
                    context.delete(result)
                    print("\(result.value(forKey: "name")!) has been deleted")
                }
            }
            saveContext()
        
        } catch {
            print("Error occurred while clearing data")
            abort()
        }
        
    }

    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
