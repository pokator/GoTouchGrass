//
//  TimerDoneViewController.swift
//  GoTouchGrass
//
//  Created by Sean Dudo on 4/7/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseFirestore
import Foundation

class TimerDoneViewController: UIViewController {
    
    var checkList = [ChecklistItem]()
    var timeDone = 0
    var delegate: UIViewController!
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var taskCompletionLabel: UILabel!
    @IBOutlet weak var congratsText: UILabel!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("total time: ", defaults.integer(forKey: "totalTime"))
        print("num breaks: ", defaults.integer(forKey: "numBreaks"))
        
        currentTimeLabel.text = String(Float(timeDone / 60)) + " minutes"
        totalTimeLabel.text = totalTimeCalc(timeDone: timeDone)
        let numTaskComp = numTasksDone()
        taskCompletionLabel.text = "\(numTaskComp) out of \(checkList.count) tasks completed!"

        if numTaskComp == checkList.count && checkList.count != 0 {
            congratsText.text = "Well done! You got all your tasks done!"
        } else {
            congratsText.text = ""
        }
    }
    
    // returns the number of task done along with storing the tasks, and its length
    // to the users database
    func numTasksDone() -> Int {
        var count = 0
        guard let uid = Auth.auth().currentUser?.uid else {
          return 0
        }
        
        var timerMap: [String: Any] = [:]
        let timerlength:Int = timeDone
        var completedTask: [String] = []

        for tasks in checkList {
            if tasks.isChecked {
                completedTask.append(tasks.title)
                count += 1
            }
        }
        
        timerMap["length"] = timerlength
        timerMap["tasks"] = completedTask

        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy"
        let formattedDate = dateFormatter.string(from: currentDate)

        // Reference to the "days" subcollection
        let daysCollectionRef = db.collection("users").document(uid).collection("days")

        // Query all documents in the "days" subcollection
        daysCollectionRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                // Iterate through the documents
                var foundDocument: DocumentSnapshot?
                for document in querySnapshot!.documents {
                    if let day = document.data()["day"] as? String, day == formattedDate {
                        // Found a document where "day" corresponds to the current day
                        foundDocument = document
                        break
                    }
                }
                // Check if a document was found
                if let existingDocument = foundDocument {
                    // Document exists for the current day
                    print("Document exists for current day. ID: \(existingDocument.documentID)")
                    // Access the "timers" array if needed
                    if var timers = existingDocument.data()?["timers"] as? [[String:Any]]{
                        //Add the timer and update
                        timers.append(timerMap)
                        
                        existingDocument.reference.updateData(["timers": timers]) { (error) in
                            if let error = error {
                                print("Error updating")
                            } else {
                                print("Updated")
                            }
                        }
                    } else {
                        print("Timers array not found or not of expected type")
                    }
                } else {
                    // Document doesn't exist for the current day, create a new document
                    var newTimers: [[String: Any]] = []
                    newTimers.append(timerMap)
                    let newData: [String: Any] = [
                        "day": formattedDate,
                        "timers": newTimers
                    ]
                    // Add the new document to the "days" subcollection
                    daysCollectionRef.addDocument(data: newData) { (error) in
                        if let error = error {
                            print("Error adding document: \(error)")
                        } else {
                            print("New document added for current day.")
                        }
                    }
                }
            }
        }
        return count
    }
    
    func totalTimeCalc(timeDone:Int) -> String {
        // TODO : need to update timeDone to use coredata of total time
        let seconds = timeDone
        let minutes = Float(timeDone / 60)
        let hours = minutes / 60
        let days = hours / 24
        
        let minutesString = String(format: "%.2f", minutes)
        let hoursString = String(format: "%.2f", hours)
        let daysString = String(format: "%.2f", days)

        let statsText = "\(seconds) seconds \n\n \(minutesString) minutes \n\n \(hoursString) hours\n\n \(daysString) days"
        
        return statsText
    }

    // Inside the prepareForSegue method of your source view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapTab" {
            // Get a reference to the tab bar controller
            if let tabBarController = self.tabBarController {
                // Set the desired tab index
                tabBarController.selectedIndex = 2 // Set it to the index of the tab you want to navigate to
            }
        }
    }
}
