//
//  ProfileSettingsViewController.swift
//  GoTouchGrass
//
//  Created by Kayla Han on 3/15/24.
//

import UIKit
import FirebaseAuth

class ProfileSettingsViewController: UIViewController {
    
    @IBOutlet weak var newEmailField: UITextField!
    
    @IBOutlet weak var newUsernameField: UITextField!
    
    @IBOutlet weak var newPasswordField: UITextField!
    
    @IBOutlet weak var confirmNewPasswordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let user = Auth.auth().currentUser
//        var credential: AuthCredential
//
//        // Prompt the user to re-provide their sign-in credentials
//
//        user?.reauthenticate(with: credential) { error,<#arg#>  in
//          if let error = error {
//            // An error happened.
//          } else {
//            // User re-authenticated.
//          }
//        }
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        // Change email
        // TODO: actual email changing currently disabled
        if ((newEmailField.text?.isEmpty) != true) {
            print("Changing email")
            //Auth.auth().currentUser?.sendEmailVerification(beforeUpdatingEmail:  newEmailField.text!) { error in
              // ...
            //}
        }
        
        // Change username
        if (((newUsernameField.text?.isEmpty) != true)) {
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            print("Changing username")
            changeRequest?.displayName = newUsernameField.text!
            changeRequest?.commitChanges { error in
                // ...
            }
        }
        
        // Change password
        if ((newPasswordField.text?.isEmpty) != true && (confirmNewPasswordField.text?.isEmpty) != true) {
            if (newPasswordField.text == confirmNewPasswordField.text) {
                print("Changing password")
                Auth.auth().currentUser?.updatePassword(to: newPasswordField.text!) { error in
                    // ...
                }
            } else {
                print("Passwords don't match")
            }
        }
        Auth.auth().currentUser?.reload()
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        
        // Confirm before deletion
        let controller = UIAlertController(
            title: "Confirm deletion", message: "Are you sure you want to delete your account?",
            preferredStyle: .alert)
        // TODO: actual account deletion currently disabled
        controller.addAction(UIAlertAction(
            title: "Yes",
            style: .default)
                             {  (action) in
                                let user = Auth.auth().currentUser
                                 
                                 //user?.delete { error in
                                  //   if let error = error {
                                         // An error happened.
                                   //  } else {
                                         // Account deleted.
                                         print("Account deleted")
                                   //  }
                             //    }
                             })
        controller.addAction(UIAlertAction(
            title: "No",
            style: .cancel)
                             {  (action) in })
        present(controller,animated: true)
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
