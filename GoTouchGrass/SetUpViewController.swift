//
//  SetUpViewController.swift
//  GoTouchGrass
//
//  Created by Kayla Han on 3/16/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

let defaults = UserDefaults.standard

class SetUpViewController: UIViewController {
    
    let setupSuccessSegueID = "setupSuccessSegueIdentifier"
    var validUsername : Bool = false

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var locRadiusSlider: UISlider!
    
    @Published var newDataText: String = "set up data success"
    
    var setLocRad:Float = 0.0
    var setPref0:Bool = false
    var setPref1:Bool = false
    var setPref2:Bool = false
    var setPref3:Bool = false
    var setPref4:Bool = false
    
    var setRecActivityPref:Bool = false
    var setShoppingPref:Bool = false
    
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
        
        setLocRad = locRadiusSlider.value
        
// debug login for faster database testing
//        Auth.auth().signIn(withEmail: "test@gmail.com",
//                           password: "test123"){
//            (authResult, error) in
//            if (error as NSError?) != nil {
//                print("Unable to log in")
//            } else {
//                print("Logged in")
//            }
//        }
    }
    
    //  TODO: store preferences
    @IBAction func savePressed(_ sender: Any) {
        if (usernameField.text!.isEmpty != true) {
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = usernameField.text!
            changeRequest?.commitChanges { error in
                // ...
            }
            if (changeRequest != nil) {
                print("Username success")
                defaults.set(setPref0, forKey: "prefFood")
                defaults.set(setPref1, forKey: "prefGym")
                defaults.set(setPref2, forKey: "prefParks")
                defaults.set(setPref3, forKey: "prefRec")
                defaults.set(setPref4, forKey: "prefShop")
                defaults.set(setLocRad, forKey: "locRadius")
                print(defaults.dictionaryRepresentation())
                //newDataText = (dataField.text ?? "")
                // 1
                guard let databasePath = databasePath else {
                  return
                }

                // 2
                if newDataText.isEmpty {
                  return
                }

                // 3
                let userPrefs = UserPrefsModel(username: usernameField.text ?? "", prefFood:setPref0, prefGym:setPref1, prefParks:setPref2, prefRec:setPref3, prefShop:setPref4, timeDone:5, totalTime:0, taskNum:0, locRadius:setLocRad)

                do {
                  // 4
                  let data = try encoder.encode(userPrefs)

                  // 5
                  let json = try JSONSerialization.jsonObject(with: data)

//                  // 6
//                  databasePath.childByAutoId()
//                    .setValue(json)
                    
                    databasePath.updateChildValues(json as! [AnyHashable : Any])

                } catch {
                  print("an error occurred", error)
                }
                performSegue(withIdentifier: "setupSuccessSegueIdentifier", sender: self)
            }
            Auth.auth().currentUser?.reload()
        } else {
            let controller = UIAlertController(
                title: "Missing username",
                message: "Please provide a valid username.",
                preferredStyle: .alert)
            
            controller.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(controller,animated: true)
        }
    }
    
    // When a modification is made to the location radius sliders in miles
    @IBAction func onLocRadiusChanged(_ sender: Any) {
        setLocRad = locRadiusSlider.value
        radiusLabel.text = "Location radius: " + String(setLocRad) + " mi"
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
        setPref0 = !setPref2
    }
    
    // Setting shopping activity preference
    @IBAction func onPref3ValChanged(_ sender: Any) {
        setPref1 = !setPref3
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
