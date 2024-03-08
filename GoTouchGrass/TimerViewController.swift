//
//  TimerViewController.swift
//  GoTouchGrass
//
//  Created by Sean Dudo on 3/6/24.
//

import UIKit
import UserNotifications

class TimerViewController: UIViewController {

    @IBOutlet weak var timerText: UILabel!
    @IBOutlet weak var timerSlider: UISlider!
    @IBOutlet weak var startResetButton: UIButton!
    
    var timer:Timer = Timer()
    var count:Int = 5
    var timerCounting:Bool = false
    
    // Most of the timer code was from youtube video https://www.youtube.com/watch?v=3TbdoVhgQmE

    // Variables
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setting up notifications for the timer!
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            // Handle the response if needed
        }

        startResetButton.setTitleColor(UIColor.green, for: .normal)
        timerText.text = makeTimeString(minutes: 0, seconds: 5)
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        if (timerCounting) {
            timerCounting = false
            timer.invalidate()
            startResetButton.setTitle("START", for: .normal)
            startResetButton.setTitleColor(UIColor.green, for: .normal)
            self.timerText.text = makeTimeString(minutes: 25, seconds: 0)
            count = 1500
        } else {
            timerCounting = true
            startResetButton.setTitle("RESET", for: .normal)
            startResetButton.setTitleColor(UIColor.red, for: .normal)
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
        }
        
    }
    
    @objc func timerCounter () -> Void {
        if count == 0 {
            showNotification()
            timer.invalidate()
        } else {
            count = count - 1
            let time = secondstoMinutesSeconds(seconds: count)
            let timeString = makeTimeString(minutes: time.1, seconds: time.0)
            timerText.text = timeString
        }
    }
    
    func showNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Timer Completed"
        content.body = "Your timer has reached 0 seconds!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: "timerNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["timerNotification"])
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }

    }
    
    func secondstoMinutesSeconds (seconds: Int) -> (Int, Int) {
        return ((seconds % 3600) % 60, ((seconds % 3600) / 60))
    }
    
    func makeTimeString(minutes: Int, seconds: Int) -> String {
        var timeString = ""
        timeString += String(format: "%02d", minutes)
        timeString += " : "
        timeString += String(format: "%02d", seconds)
        return timeString
    }
    

}
