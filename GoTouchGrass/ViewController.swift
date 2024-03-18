//
//  ViewController.swift
//  GoTouchGrass
//
//  Created by Sourav Banerjee on 2/26/24.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {
    
    let loginSegue = "LoginSegueIdentifier"
    let homeSegue = "HomeSegueIdentifier"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("loading")
    }

    override func viewDidAppear(_ animated: Bool) {
        let user = Auth.auth().currentUser
        
        if (user != nil) {
            print("logged in")
            performSegue(withIdentifier: homeSegue, sender: nil)

        } else {
            print("no one logged in")
            performSegue(withIdentifier: loginSegue, sender: nil)
        }
    }


}

