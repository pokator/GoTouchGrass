//
//  SetUpViewController.swift
//  GoTouchGrass
//
//  Created by Kayla Han on 3/16/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseFirestore

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
    
    let db = Firestore.firestore()
    
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

            }
            if (changeRequest != nil) {
                print("Username success")
                defaults.set(setPref0, forKey: "prefFood")
                defaults.set(setPref1, forKey: "prefGym")
                defaults.set(setPref2, forKey: "prefParks")
                defaults.set(setPref3, forKey: "prefRec")
                defaults.set(setPref4, forKey: "prefShop")
                defaults.set(setLocRad, forKey: "locRadius")
                defaults.set(0, forKey: "totalTime")
                defaults.set(0, forKey: "tasksCompleted")
                defaults.set(0, forKey: "numBreaks")
                //print(defaults.dictionaryRepresentation())
                //newDataText = (dataField.text ?? "")
                // 1
                guard let databasePath = databasePath else {
                  return
                }

                // 3
                let userPrefs = UserPrefsModel(username: usernameField.text ?? "username missing", prefFood:setPref0, prefGym:setPref1, prefParks:setPref2, prefRec:setPref3, prefShop:setPref4, totalTime:0, tasksCompleted:0, numBreaks:0, locRadius:setLocRad)
                
                print("user prefs set up: ", userPrefs)
                
                
                do {
                  let data = try encoder.encode(userPrefs)

                  let json = try JSONSerialization.jsonObject(with: data)
                    
                    databasePath.updateChildValues(json as! [AnyHashable : Any])

                } catch {
                  print("an error occurred", error)
                }
                
                guard let uid = Auth.auth().currentUser?.uid else {
                  return
                }

                // Define the data you want to store in the document
                let data: [String: Any] = [
                    "name": "John Doe",
                    "age": 30,
                    "city": "New York"
                ]

                db.collection("users").document(uid).setData(data) { error in
                    if let error = error {
                        print("Error adding user document: \(error)")
                    } else {
                        print("User document added with UID: \(uid)")
                        // Create a subcollection called "days" within the user document
                        let daysCollectionRef = self.db.collection("users").document(uid).collection("days")                  
                    }
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
    
    // Setting parks activity preference
    @IBAction func onPref2ValChanged(_ sender: Any) {
        setPref2 = !setPref2
    }
    
    // Setting rec activity preference
    @IBAction func onPref3ValChanged(_ sender: Any) {
        setPref3 = !setPref3
    }
    
    // Setting shopping activity preference
    @IBAction func onPref4ValChanged(_ sender: Any) {
        setPref4 = !setPref4
    }
}
