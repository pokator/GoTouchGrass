//
//  TimerViewController.swift
//  GoTouchGrass
//
//  Created by Sean Dudo on 3/6/24.
//

import UIKit
import UserNotifications

class TimerViewController: UIViewController, UNUserNotificationCenterDelegate, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var timerText: UILabel!
    @IBOutlet weak var timerSlider: UISlider!
    @IBOutlet weak var startResetButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    var checkList = [ChecklistItem]()
    var checkedNum = 0
    
    var timerDoneSegue = "Timer"
    
    var timer:Timer = Timer()
    var timeStart = 0
    var count:Int = 5
    var timerCounting:Bool = false
    
    // Most of the timer code was from youtube video https://www.youtube.com/watch?v=3TbdoVhgQmE
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the delegate of UNUserNotificationCenter to allow notifs on foreground
        UNUserNotificationCenter.current().delegate = self
        
        // setting up notifications for the timer!
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            // Handle the response if needed
        }
        
        startResetButton.setTitleColor(UIColor.green, for: .normal)
        timerText.text = makeTimeString(minutes: 0, seconds: 5)
        
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    // Interactable slider to make the timer
    @IBAction func sliderMoved(_ sender: UISlider) {
        let value = Int(sender.value)
        let minutes = value / 60
        
        count = minutes * 60
        timerText.text = makeTimeString(minutes: minutes, seconds: 0)
    }
    
    
    @IBAction func startButtonPressed(_ sender: Any) {
        if (timerCounting) {
            timerCounting = false
            timer.invalidate()
            timerSlider.isEnabled = true
            startResetButton.setTitle("START", for: .normal)
            startResetButton.setTitleColor(UIColor.green, for: .normal)
            self.timerText.text = makeTimeString(minutes: 0, seconds: 5)
            timerSlider.value = 5
            count = 5
        } else {
            timerCounting = true
            startResetButton.setTitle("RESET", for: .normal)
            startResetButton.setTitleColor(UIColor.red, for: .normal)
            timeStart = count
            timerSlider.isEnabled = false
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
        }
        
    }
    
    // Segue for timer finishing!
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == timerDoneSegue,
        let destination = segue.destination as? TimerDoneViewController { 
            destination.checkList = checkList
            destination.timeDone = timeStart
            destination.delegate = self
        }
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
        tableView.reloadData()
    }
    
    
    
    // MARK: - Timer schenanigans
    
    @objc func timerCounter () -> Void {
        if count == 0 {
            // shows notification and stops timer
            showNotification()
            timer.invalidate()
            
            // enables the slider
            timerSlider.isEnabled = true
            
            timerCounting = true
            
            // SEGUES TO NEXT SCREEN!
            performSegue(withIdentifier: timerDoneSegue, sender: self)
        } else {
            count = count - 1
            let time = secondstoMinutesSeconds(seconds: count)
            let timeString = makeTimeString(minutes: time.1, seconds: time.0)
            timerText.text = timeString
            timerSlider.value = Float(count)
        }
    }

    
    func secondstoMinutesSeconds (seconds: Int) -> (Int, Int) {
        return ((seconds % 3600) % 60, (seconds / 60))
    }
    
    func makeTimeString(minutes: Int, seconds: Int) -> String {
        var timeString = ""
        timeString += String(format: "%02d", minutes)
        timeString += " : "
        timeString += String(format: "%02d", seconds)
        return timeString
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func showNotification() {
        let notificationCenter = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Timer Completed"
        content.body = "Your timer has reached 0 seconds!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.01, repeats: false)
        let request = UNNotificationRequest(identifier: "timerNotification", content: content, trigger: trigger)

        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["timerNotification"])
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }

    // Handle notification received while the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Display the notification alert while the app is in the foreground
        completionHandler([.banner, .sound])
        
    }

}
