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
            Auth.auth().signIn(withEmail: name,
                               password: pass){
                (authResult, error) in
                if let error = error as NSError? {
                    let controller = UIAlertController(
                        title: "Login error",
                        message: "\(error.localizedDescription)",
                        preferredStyle: .alert)
                    
                    controller.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(controller,animated: true)
                }                 
                if (authResult != nil) {
                    self.performSegue(withIdentifier: "loginSuccessSegueIdentifier", sender: self)
                }
            }
        } else {
            let controller = UIAlertController(
                title: "Missing email or password",
                message: "Please provide a valid email and password.",
                preferredStyle: .alert)
            
            controller.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(controller,animated: true)
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
