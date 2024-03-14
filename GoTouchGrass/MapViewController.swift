//
//  MapViewController.swift
//  GoTouchGrass
//
//  Created by Sourav Banerjee on 3/14/24.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    let gdcLocation = CLLocation(latitude: 30.28639, longitude: -97.736667)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Check if location permissions have been set up
        if CLLocationManager.locationServicesEnabled() {
            if locationManager.authorizationStatus == .notDetermined {
                locationManager.requestAlwaysAuthorization()
            }
        }
        
        // Setup location tracking parameters
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
    }
    
    //Respond to location changes
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        
        
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
