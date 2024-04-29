//
//  MapSettingsViewController.swift
//  GoTouchGrass
//
//  Created by Emely Diaz on 4/5/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class MapSettingsViewController: UIViewController {
    
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var locRadiusSlider: UISlider!
    
    @IBOutlet weak var foodSwitch: UISwitch!
    @IBOutlet weak var gymSwitch: UISwitch!
    @IBOutlet weak var parkSwitch: UISwitch!
    @IBOutlet weak var recSwitch: UISwitch!
    @IBOutlet weak var shopSwitch: UISwitch!
    
    var setLocRad:Float = 0.0
    var setFoodPreference:Bool = false
    var setGymPreference:Bool = false
    var setParksPreference:Bool = false
    var setRecreationPreference:Bool = false
    var setShoppingPreference:Bool = false
    
    var delegate: UIViewController!
    
    private lazy var databasePath: DatabaseReference? = {
      guard let uid = Auth.auth().currentUser?.uid else {
        return nil
      }
      let ref = Database.database()
        .reference()
        .child("users/\(uid)/preferences")
      return ref
    }()

    // 3
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setFoodPreference = defaults.value(forKey: "prefFood") as! Bool
        setGymPreference = defaults.value(forKey: "prefGym") as! Bool
        setParksPreference = defaults.value(forKey: "prefParks") as! Bool
        setRecreationPreference = defaults.value(forKey: "prefRec") as! Bool
        setShoppingPreference = defaults.value(forKey: "prefShop") as! Bool
        setLocRad = defaults.value(forKey: "locRadius") as! Float
        self.updateUI()
    }
    
    func updateUI() {
        foodSwitch.isOn = defaults.value(forKey: "prefFood") as! Bool
        gymSwitch.isOn = defaults.value(forKey: "prefGym") as! Bool
        parkSwitch.isOn = defaults.value(forKey: "prefParks") as! Bool
        recSwitch.isOn = defaults.value(forKey: "prefRec") as! Bool
        shopSwitch.isOn = defaults.value(forKey: "prefShop") as! Bool
        locRadiusSlider.value = defaults.value(forKey: "locRadius") as! Float
        radiusLabel.text = "Location radius: " + String(defaults.value(forKey: "locRadius") as! Float) + " mi"
    }
    
    //  TODO: store preferences
    @IBAction func savePressed(_ sender: Any) {
        //newDataText = (dataField.text ?? "")
        // 1
        guard let databasePath = databasePath else {
            return
        }

        // 3
        let updatePrefs = [
            "prefFood":setFoodPreference,
            "prefParks":setParksPreference,
            "prefGym":setGymPreference,
            "prefRec":setRecreationPreference,
            "prefShop":setShoppingPreference,
            "locRadius":setLocRad
        ] as [String : Any]
            
        databasePath.updateChildValues(updatePrefs) { (error, _) in
            if let error = error {
                print("Error updating preferences: \(error.localizedDescription)")
            } else {
                print("Preferences updated successfully")
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Success", message: "Preferences updated successfully", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(okAction)
                    self.present(alert, animated: true)
                }
                // Call the delegate method to update preferences in the MapViewController
                if let delegate = self.delegate as? UpdateDatabase {
                    delegate.update()
                }
            }
        }
        defaults.set(setFoodPreference, forKey: "prefFood")
        defaults.set(setGymPreference, forKey: "prefGym")
        defaults.set(setParksPreference, forKey: "prefParks")
        defaults.set(setRecreationPreference, forKey: "prefRec")
        defaults.set(setShoppingPreference, forKey: "prefShop")
        defaults.set(setLocRad, forKey: "locRadius")
        print("Setting loc radius: ", String(setLocRad))
    }
    
    // When a modification is made to the location radius sliders in miles
    @IBAction func onLocRadiusChanged(_ sender: Any) {
        let roundedValue = round(locRadiusSlider.value * 10) / 10
        setLocRad = roundedValue
        radiusLabel.text = "Location radius: " + String(setLocRad) + " mi"
    }
    
    // Setting food activity preference
    @IBAction func onFoodValChanged(_ sender: Any) {
        setFoodPreference = !setFoodPreference
    }
    
    // Setting gym activity preference
    @IBAction func onGymValChanged(_ sender: Any) {
        setGymPreference = !setGymPreference
    }
    
    // Setting parks activity preference
    @IBAction func onParksValChanged(_ sender: Any) {
        setParksPreference = !setParksPreference
    }
    
    // Setting recreation activity preference
    @IBAction func onRecreationValChanged(_ sender: Any) {
        setRecreationPreference = !setRecreationPreference
    }
    
    // Setting shopping activity preference
    @IBAction func onShoppingValChanged(_ sender: Any) {
        setShoppingPreference = !setShoppingPreference
    }
}
