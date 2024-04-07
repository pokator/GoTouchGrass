//
//
//  MapViewController.swift
//  GoTouchGrass
//
//  Created by Sourav Banerjee on 3/14/24.
//

import UIKit
import CoreLocation
import MapKit
import FirebaseFirestore

typealias LocationTuple = (String, CLLocationCoordinate2D)

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    let textCellIdentifier = "TextCell"
    //    let segueIdentifier = "OperandSegueIdentifier"
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    let gdcLocation = CLLocation(latitude: 30.28639, longitude: -97.736667)
    
    var locationsList = [LocationTuple]()
    
    func getLocations(completion: @escaping ([LocationTuple]?, Error?) -> Void) {
        let db = Firestore.firestore()
        let collectionReference = db.collection("locations")
        
        collectionReference.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil, error) // Call completion with error
            } else {
                guard let documents = querySnapshot?.documents else {
                    completion([], nil) // Call completion with empty array
                    return
                }
                
                var locations: [LocationTuple] = []
                for document in documents {
                    // Access string data from document
                    let stringValue = document.get("name") as? String ?? ""
                    
                    // Access geolocation data from document
                    if let geoPoint = document.get("location") as? GeoPoint {
                        // Convert GeoPoint to CLLocationCoordinate2D
                        let location = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
                        
                        // Append tuple to array
                        locations.append((stringValue, location))
                    }
                }
                completion(locations, nil) // Call completion with locations
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if CLLocationManager.locationServicesEnabled() {
            DispatchQueue.global(qos: .background).async { [self] in
                if locationManager.authorizationStatus == .notDetermined {
                    // Wait for the locationManagerDidChangeAuthorization callback
                    // and handle the authorization there
                    locationManager.requestAlwaysAuthorization()
                } else {
                    // Authorization status is already determined, handle accordingly
                }
            }
        }

        
        mapView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        getLocations() { [self] (locations, error) in
            locationsList = locations ?? []
            tableView.reloadData()
            if let error = error {
                print("Error getting locations: \(error)")
            } else if let locations = locations {
                // Handle retrieved locations
                print("Locations: \(locations)")
                for location in locations {
                    let loc = MKPointAnnotation()
                    loc.title = location.0
                    loc.coordinate = location.1
                    mapView.addAnnotation(loc)
                }
            }
        }
        
        mapView.showAnnotations(mapView.annotations, animated: true)
        mapView.reloadInputViews()
        
        
        // Setup location tracking parameters
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
    }
    
    //Respond to location changes
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        }
    }
    
    //Pulled
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        
        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        return annotationView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        let row = indexPath.row
        // Accessing the title text
        cell.textLabel?.text = locationsList[row].0
        
        // Assuming currentLocation is your current location's CLLocationCoordinate2D
        let currentLocation = locationsList[row].1
        // Create CLLocation objects for both coordinates
        let currentCLLocation = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        guard let targetCLLocation = locationManager.location else { return cell }
        
        // Calculate the distance between the two CLLocation objects
        let distanceInMeters = currentCLLocation.distance(from: targetCLLocation)
        
        // Convert distance to miles
        let distanceInMiles = distanceInMeters / 1609.34 // 1 meter is approximately 0.000621371 miles
        
        // Accessing the subtitle text
        cell.detailTextLabel?.text = String(format: "%.1f", distanceInMiles) + " miles away"
        
        return cell
    }
}
