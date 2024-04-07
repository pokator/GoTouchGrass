//
//  TimerDoneViewController.swift
//  GoTouchGrass
//
//  Created by Sean Dudo on 4/7/24.
//

import UIKit

class TimerDoneViewController: UIViewController {

    var checkList = [ChecklistItem]()
    var timeDone = 0
    var delegate: UIViewController!
    
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var taskCompletionLabel: UILabel!
    @IBOutlet weak var congratsText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        currentTimeLabel.text = "\(timeDone / 60) minutes spent focused!"
        totalTimeLabel.text = totalTimeCalc()
        taskCompletionLabel.text = "\(numTasksDone()) out of \(checkList.count) tasks completed!"
        
        if numTasksDone() == checkList.count {
            congratsText.text = "Well done! You got all your tasks done!"
        } else {
            congratsText.text = ""
        }
        
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
    
    func totalTimeCalc() -> String {
        
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
