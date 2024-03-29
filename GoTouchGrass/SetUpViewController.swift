//
//  SetUpViewController.swift
//  GoTouchGrass
//
//  Created by Kayla Han on 3/16/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class SetUpViewController: UIViewController {
    
    let setupSuccessSegueID = "setupSuccessSegueIdentifier"
    
    var validUsername : Bool = false

    @IBOutlet weak var usernameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    //  TODO: store preferences
    @IBAction func savePressed(_ sender: Any) {
        if (usernameField.text!.isEmpty != true) {
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = usernameField.text!
            changeRequest?.commitChanges { error in
                // ...
            }
            validUsername = true
            Auth.auth().currentUser?.reload()
        }
    }
    
    @IBAction func onLocRadiusChanged(_ sender: Any) {
    }
    
    @IBAction func onPref1ValChanged(_ sender: Any) {
    }
    
    @IBAction func onPref2ValChanged(_ sender: Any) {
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == setupSuccessSegueID {
            if validUsername {
                return true
            }
            return false
        }
        return true
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
