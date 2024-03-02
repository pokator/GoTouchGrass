//
//  LoginViewController.swift
//  GoTouchGrass
//
//  Created by Kayla Han on 3/1/24.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userIDField: UITextField!    // The text field to enter username
    @IBOutlet weak var passwordField: UITextField!  // The text field to enter password
    @IBOutlet weak var loginLabel: UILabel!         // The label that displays login status
    
    let loginSegueID = "loginSuccssSegueIdentifier"
    let registerSegueID = "registerSegueIdentifier"
    
    var validLogin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        userIDField.delegate = self
        passwordField.delegate = self
    }

    // TODO: Firebase
    @IBAction func buttonPressed(_ sender: Any) {
        let name = userIDField.text!
        let pass = passwordField.text!
        if (!name.isEmpty && !pass.isEmpty) {
            validLogin = true
        } else {
            var message = "Invalid login"
            loginLabel.text = message
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == loginSegueID && validLogin,
           let destination = segue.destination as? HomeViewController {
            // prep here
        }
        if segue.identifier == registerSegueID && validLogin,
           let destination = segue.destination as? RegisterViewController {
            // prep here
        }
    }
}
