//
//  TimerDoneViewController.swift
//  GoTouchGrass
//
//  Created by Sean Dudo on 4/7/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class TimerDoneViewController: UIViewController {

    private lazy var databasePath: DatabaseReference? = {
      // 1
      guard let uid = Auth.auth().currentUser?.uid else {
        return nil
      }

      // 2
      let ref = Database.database()
        .reference()
        .child("users/\(uid)/preferences")
      return ref
    }()

    // 3
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    var checkList = [ChecklistItem]()
    var timeDone = 0
    var delegate: UIViewController!
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var taskCompletionLabel: UILabel!
    @IBOutlet weak var congratsText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 2
        databasePath?
            .observe(.value) { [weak self] snapshot,error  in

            // 3
            guard
              let self = self,
              var json = snapshot.value as? [String: Any]
            else {
              return
            }

            // 4
            json["id"] = snapshot.key
    
            do {
                // 5
                let thoughtData = try JSONSerialization.data(withJSONObject: json)
                // 6
                let prefs = try self.decoder.decode(UserPrefsModel.self, from: thoughtData)
            
                // 7
                currentTimeLabel.text = "\(prefs.timeDone / 60) minutes spent focused!"
                totalTimeLabel.text = totalTimeCalc(timeDone:prefs.timeDone)
                taskCompletionLabel.text = "\(numTasksDone()) out of \(checkList.count) tasks completed!"
                
                if numTasksDone() == checkList.count {
                    congratsText.text = "Well done! You got all your tasks done!"
                } else {
                    congratsText.text = ""
                }
            } catch {
              print("an error occurred", error)
            }
          }
        currentTimeLabel.text = String(Float(timeDone / 60)) + " minutes"
        totalTimeLabel.text = totalTimeCalc(timeDone: timeDone)
        // Do any additional setup after loading the view.
    }
    
    func numTasksDone() -> Int {
        var count = 0
        
        for tasks in checkList {
            if tasks.isChecked {
                count += 1
            }
        }
        return count
    }
    
    func totalTimeCalc(timeDone:Int) -> String {
        
        // TODO : need to update timeDone to use coredata of total time
        print("Time done retrieved: ", timeDone)
        
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
