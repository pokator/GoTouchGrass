//
//  SettingsViewController.swift
//  GoTouchGrass
//
//  Created by Kayla Han on 4/29/24.
//

import UIKit
import CoreLocation
import UserNotifications

class SettingsViewController: UIViewController {

    var locationManager = CLLocationManager()
    
    @IBOutlet weak var NotifSwitch: UISwitch!
    
    @IBOutlet weak var LocSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            if(settings.authorizationStatus == .authorized) {
                self.NotifSwitch.isOn =  true
            }
        }

        LocSwitch.isOn = CLLocationManager.locationServicesEnabled()
    }

    @IBAction func onToggleNotifs(_ sender: Any) {
        if (NotifSwitch.isOn == false) {
            UIApplication.shared.registerForRemoteNotifications()
        } else {
            UIApplication.shared.unregisterForRemoteNotifications()
        }
    }
    
    @IBAction func onToggleLoc(_ sender: Any) {
        if (LocSwitch.isOn == false) {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.stopUpdatingLocation()
        }

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
