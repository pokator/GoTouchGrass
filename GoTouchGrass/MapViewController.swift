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
import FirebaseDatabase
import FirebaseAuth

typealias LocationTuple = (String, CLLocationCoordinate2D)

protocol UpdateDatabase {
    func update()
}

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate, UpdateDatabase {
    
    
    @IBOutlet weak var tableView: UITableView!
    let textCellIdentifier = "TextCell"
    let segueIdentifier = "MapSettings"
    
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    let gdcLocation = CLLocation(latitude: 30.28639, longitude: -97.736667)
    
    var locationsList = [LocationTuple]()
    
    var foodPreference:Bool = true
    var gymPreference:Bool = true
    var parksPreference:Bool = true
    var recreationPreference:Bool = true
    var shoppingPreference:Bool = true
    var setLocRad:Float = 5.0
    
    private lazy var databasePath: DatabaseReference? = {
      guard let uid = Auth.auth().currentUser?.uid else {
        return nil
      }
      let ref = Database.database()
        .reference()
        .child("users/\(uid)/preferences")
      return ref
    }()
    
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
        
        // Setup location tracking parameters
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        mapView.showsUserLocation = true
        
        accessUser()
        tableView.reloadData()
    }
    
    //Queries Firestore for locations matching the user's preferences.
    func getLocations(completion: @escaping ([LocationTuple]?, Error?) -> Void) {
        let db = Firestore.firestore()
        let collectionReference = db.collection("locations")
        
        var queryConditions:[Filter] = []
        
        // Build query depending on user preferences.
        if foodPreference {
            queryConditions.append(Filter.whereField("food", isEqualTo: true))
        }
        if gymPreference {
            queryConditions.append(Filter.whereField("gym", isEqualTo: true))
        }
        if parksPreference {
            queryConditions.append(Filter.whereField("parks", isEqualTo: true))
        }
        if recreationPreference {
            queryConditions.append(Filter.whereField("recreation", isEqualTo: true))
        }
        if shoppingPreference {
            queryConditions.append(Filter.whereField("shopping", isEqualTo: true))
        }
        
        let query = collectionReference.whereFilter(Filter.orFilter(queryConditions))
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil, error)
            } else {
                guard let documents = querySnapshot?.documents else {
                    completion([], nil)
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
                completion(locations, nil)
            }
        }
    }
    
    //Gets the user's preferences.
    func accessUser() {
        foodPreference = defaults.bool(forKey: "prefFood")
        gymPreference = defaults.bool(forKey: "prefGym")
        parksPreference = defaults.bool(forKey: "prefParks")
        recreationPreference = defaults.bool(forKey: "prefRec")
        shoppingPreference = defaults.bool(forKey: "prefShop")
        setLocRad = defaults.float(forKey: "locRadius")
        
        buildLocationData()
    }
    
    func buildLocationData() {
        getLocations() { [self] (locations, error) in
            locationsList.removeAll()
            let rawLocationsList = locations ?? []
            if let targetCLLocation = locationManager.location {
                print("We have it")
                //We have access to location, can filter further (by distance)
                for location in rawLocationsList {
                    let currentLocation = location.1
                    let currentCLLocation = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
                    
                    // Calculate the distance between the two locations
                    let distanceInMeters = currentCLLocation.distance(from: targetCLLocation)
                    
                    // Convert distance to miles
                    let distanceInMiles = distanceInMeters / 1609.34
                    
                    if Float(distanceInMiles) <= setLocRad {
                        locationsList.append(location)
                    }
                }
            }
            tableView.reloadData()
            if let error = error {
                print("Error getting locations: \(error)")
            } else if let locations = locations {
                // Handle retrieved locations
                locationsList = sortLocationsByDistance(locations: locations)
                mapView.removeAnnotations(mapView.annotations)
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
    }
    
    func update() {
        accessUser()
    }
    
    func sortLocationsByDistance(locations: [LocationTuple]) -> [LocationTuple] {
        guard let currentLocation = locationManager.location else {
            return locations
        }
        
        // Sort locations based on distance from current location
        let sortedLocations = locations.sorted { (location1, location2) -> Bool in
            let location1CLLocation = CLLocation(latitude: location1.1.latitude, longitude: location1.1.longitude)
            let location2CLLocation = CLLocation(latitude: location2.1.latitude, longitude: location2.1.longitude)
            let distance1 = currentLocation.distance(from: location1CLLocation)
            let distance2 = currentLocation.distance(from: location2CLLocation)
            return distance1 < distance2
        }
        
        return sortedLocations
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
        
        let color = UIColor(red: 1.0, green: 0.514, blue: 0.376, alpha: 1.0)
        annotationView?.tintColor = color
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get the selected location's coordinates from the locationsList
        let selectedLocation = locationsList[indexPath.row]
        let latitude = selectedLocation.1.latitude
        let longitude = selectedLocation.1.longitude
        
        // Open Google Maps with the selected location's coordinates
        openGoogleMaps(latitude: latitude, longitude: longitude)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? MKPointAnnotation {
            openGoogleMaps(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        }
    }
    
    // Function to open Google Maps with specified location
    func openGoogleMaps(latitude: Double, longitude: Double) {
        if let url = URL(string: "comgooglemaps://?saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // Google Maps app is not installed, open in browser
                if let webURL = URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(latitude),\(longitude)&travelmode=driving") {
                    UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueIdentifier,
           let nextVC = segue.destination as? MapSettingsViewController {
            nextVC.delegate = self
        }
    }
}
