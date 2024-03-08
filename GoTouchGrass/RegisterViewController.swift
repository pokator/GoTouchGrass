//
//  RegisterViewController.swift
//  GoTouchGrass
//
//  Created by Kayla Han on 3/1/24.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
    
    let registerSuccessSegueID = "registerSuccessSegueIdentifier"

    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var confirmPassField: UITextField!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    var validRegister = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordField.isSecureTextEntry = true
        confirmPassField.isSecureTextEntry = true
        // Do any additional setup after loading the view.
    }

    @IBAction func onRegisterPressed(_ sender: Any) {
        if (((emailField.text?.isEmpty) == false) && ((passwordField.text?.isEmpty) == false)) {
            let name = emailField.text!
            let pass = passwordField.text!
            if (!name.isEmpty && !pass.isEmpty && (pass == confirmPassField.text)) {
                //can register
                validRegister = true
                Auth.auth().createUser(withEmail: emailField.text!,
                                   password: passwordField.text!) {
                    (authResult, error) in
                    if let error = error as NSError? {
                        self.statusLabel.text = "\(error.localizedDescription)"
                    } else {
                        self.statusLabel.text = ""
                    }
                }
            }
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == registerSuccessSegueID {
            if validRegister {
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
