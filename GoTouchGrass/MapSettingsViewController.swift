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
    
    @IBOutlet weak var locRadiusSlider: UISlider!
    
    @IBOutlet weak var foodSwitch: UISwitch!
    @IBOutlet weak var gymSwitch: UISwitch!
    @IBOutlet weak var parkSwitch: UISwitch!
    @IBOutlet weak var recSwitch: UISwitch!
    @IBOutlet weak var shopSwitch: UISwitch!
    
    var setLocRad:Float = 0.0
    var setPref0:Bool = false
    var setPref1:Bool = false
    var setPref2:Bool = false
    var setPref3:Bool = false
    var setPref4:Bool = false
    
    private lazy var databasePath: DatabaseReference? = {
      // 1
      guard let uid = Auth.auth().currentUser?.uid else {
        return nil
      }

      // 2
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
        
        if (foodSwitch.isOn) {
            setPref0 = defaults.bool(forKey: "prefFood")
        }
        if (gymSwitch.isOn) {
            setPref1 = defaults.bool(forKey: "prefGym")
        }
        if (parkSwitch.isOn) {
            setPref2 = defaults.bool(forKey: "prefParks")
        }
        if (shopSwitch.isOn) {
            setPref3 = defaults.bool(forKey: "prefRec")
        }
        if (shopSwitch.isOn) {
            setPref4 = defaults.bool(forKey: "prefShop")
        }
        setLocRad = locRadiusSlider.value
        // Do any additional setup after loading the view.
    }
    
    //  TODO: store preferences
    @IBAction func savePressed(_ sender: Any) {
        //newDataText = (dataField.text ?? "")
        // 1
        guard let databasePath = databasePath else {
            return
        }

        // 3
        let updatePrefs = ["prefFood":setPref0, "prefGym":setPref1, "prefRec":setPref2, "prefShop":setPref3, "locRadius":setLocRad] as [String : Any]
            databasePath.updateChildValues(updatePrefs)
        
        defaults.set(setPref0, forKey: "prefFood")
        defaults.set(setPref1, forKey: "prefGym")
        defaults.set(setPref2, forKey: "prefParks")
        defaults.set(setPref3, forKey: "prefRec")
        defaults.set(setPref4, forKey: "prefShop")
        defaults.set(setLocRad, forKey: "locRadius")
    }
    
    // When a modification is made to the location radius sliders in miles
    @IBAction func onLocRadiusChanged(_ sender: Any) {
        setLocRad = locRadiusSlider.value
    }
    
    
    // Setting food activity preference
    @IBAction func onPref0ValChanged(_ sender: Any) {
        setPref0 = !setPref0
    }
    
    // Setting gym activity preference
    @IBAction func onPref1ValChanged(_ sender: Any) {
        setPref1 = !setPref1
    }
    
    // Setting rec activity preference
    @IBAction func onPref2ValChanged(_ sender: Any) {
        setPref2 = !setPref2
    }
    
    // Setting shopping activity preference
    @IBAction func onPref3ValChanged(_ sender: Any) {
        setPref3 = !setPref3
    }
    
    // Setting shopping activity preference
    @IBAction func onPref4ValChanged(_ sender: Any) {
        setPref3 = !setPref4
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
