//
//  TimerViewController.swift
//  GoTouchGrass
//
//  Created by Sean Dudo on 3/6/24.
//

import UIKit
import UserNotifications

class TimerViewController: UIViewController, UNUserNotificationCenterDelegate{

    @IBOutlet weak var timerText: UILabel!
    @IBOutlet weak var timerSlider: UISlider!
    @IBOutlet weak var startResetButton: UIButton!
    
    var timer:Timer = Timer()
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
            timerSlider.isEnabled = false
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerCounter), userInfo: nil, repeats: true)
        }
        
    }
    
    @objc func timerCounter () -> Void {
        if count == 0 {
            // shows notification and stops timer
            showNotification()
            timer.invalidate()
            
            // enables the slider
            timerSlider.isEnabled = true
            
            // resets the start button
            startResetButton.setTitle("START", for: .normal)
            startResetButton.setTitleColor(UIColor.green, for: .normal)
            
            timerCounting = false
        } else {
            count = count - 1
            let time = secondstoMinutesSeconds(seconds: count)
            let timeString = makeTimeString(minutes: time.1, seconds: time.0)
            timerText.text = timeString
        }
    }
    
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

    // Handle notification received while the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Display the notification alert while the app is in the foreground
        completionHandler([.banner, .sound])
        
    }

}
