//
//  HomeViewController.swift
//  GoTouchGrass
//
//  Created by Kayla Han on 3/1/24.
//

import UIKit
import CoreLocation

class HomeViewController: UIViewController {

    var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

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
