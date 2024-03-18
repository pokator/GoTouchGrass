//
//  LoginViewController.swift
//  GoTouchGrass
//
//  Created by Kayla Han on 3/1/24.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userIDField: UITextField!    // The text field to enter username
    @IBOutlet weak var passwordField: UITextField!  // The text field to enter password
    @IBOutlet weak var loginLabel: UILabel!         // The label that displays login status
    
    let loginSegueID = "loginSuccessSegueIdentifier"
    let registerSegueID = "registerSegueIdentifier"
    
    var validLogin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        userIDField.delegate = self
        passwordField.delegate = self
        passwordField.isSecureTextEntry = true
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        let name = userIDField.text!
        let pass = passwordField.text!
        if (!name.isEmpty && !pass.isEmpty) {
            validLogin = true
            self.loginLabel.text = "Valid login"
            Auth.auth().signIn(withEmail: name,
                               password: pass){
                (authResult, error) in
                if let error = error as NSError? {
                    self.loginLabel.text = "\(error.localizedDescription)"
                } else {
                    self.loginLabel.text = "Invalid login"
                }
            }
            
        } else {
            loginLabel.text = "Invalid login"
        }
    }

    // Called when 'return' key pressed
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user clicks on the view outside of the UITextField
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == loginSegueID {
            if validLogin {
                return true
            }
            return false
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == loginSegueID,
           let destination = segue.destination as? HomeViewController {
            // prep here
        }
        if segue.identifier == registerSegueID,
           let destination = segue.destination as? RegisterViewController {
            // prep here
        }
    }
}
