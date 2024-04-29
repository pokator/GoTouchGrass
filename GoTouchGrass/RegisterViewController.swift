//
//  RegisterViewController.swift
//  GoTouchGrass
//
//  Created by Kayla Han on 3/1/24.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
    
    let registerSuccessSegueID = "registerSuccessSegueID"

    @IBOutlet weak var emailField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBOutlet weak var confirmPassField: UITextField!
    
    @IBOutlet weak var statusLabel: UILabel!
    
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
                Auth.auth().createUser(withEmail: emailField.text!,
                                   password: passwordField.text!) {
                    (authResult, error) in
                    if let error = error as NSError? {
                        let controller = UIAlertController(
                            title: "Registration error",
                            message: "\(error.localizedDescription)",
                            preferredStyle: .alert)
                        
                        controller.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(controller,animated: true)
                    }
                    //can register
                    if (authResult != nil) {
                        self.performSegue(withIdentifier: "registerSuccessSegueID", sender:self)
                    }
                }
            } else if (pass != confirmPassField.text) {
                let controller = UIAlertController(
                    title: "Mismatched password",
                    message: "Please confirm your password.",
                    preferredStyle: .alert)
                
                controller.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(controller,animated: true)
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
