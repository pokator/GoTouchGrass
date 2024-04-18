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
    @IBOutlet weak var recSwitch: UISwitch!
    @IBOutlet weak var shopSwitch: UISwitch!
    
    var setLocRad:Float = 0.0
    var setPref0:Bool = false
    var setPref1:Bool = false
    var setPref2:Bool = false
    var setPref3:Bool = false
    
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

        // Do any additional setup after loading the view.
        Auth.auth().signIn(withEmail: "test@gmail.com",
                           password: "test123"){
            (authResult, error) in
            if let error = error as NSError? {
                print("Unable to log in")
            } else {
                print("Logged in")
            }
        }
        
        // 2
        databasePath?
            .observe(.value) { [weak self] snapshot,error  in

            // 3
            guard
              let self = self,
              var json = snapshot.value as? [String: Any]
            else {
              return
            }

            // 4
            json["id"] = snapshot.key
    
                do {
                    // 5
                    let thoughtData = try JSONSerialization.data(withJSONObject: json)
                    // 6
                    let prefs = try self.decoder.decode(UserPrefsModel.self, from: thoughtData)
                    
                    locRadiusSlider.value = prefs.locRadius
                    foodSwitch.isOn = prefs.prefFood
                    gymSwitch.isOn = prefs.prefGym
                    recSwitch.isOn = prefs.prefRec
                    shopSwitch.isOn = prefs.prefShop
                    
                } catch {
                  print("an error occurred", error)
                }
              }
        if (foodSwitch.isOn) {
            setPref0 = true
        } 
        if (gymSwitch.isOn) {
            setPref1 = true
        } 
        if (recSwitch.isOn) {
            setPref2 = true
        } 
        if (shopSwitch.isOn) {
            setPref3 = true
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
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
