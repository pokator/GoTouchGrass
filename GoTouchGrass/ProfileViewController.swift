//
//  ProfileViewController.swift
//  GoTouchGrass
//
//  Created by Kayla Han on 3/15/24.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    var username : String = ""
    let logoutSegueID = "logOutSegueIdentifier"
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        username = Auth.auth().currentUser!.displayName ?? "Missing username"
       // print("User: ", username)
        // Do any additional setup after loading the view.
        usernameLabel.text = username
    }
    
    
    
    @IBAction func logOutPressed(_ sender: Any) {
        // Confirm before loug out
        let controller = UIAlertController(
            title: "Confirm log out", message: "Are you sure you want to log out?",
            preferredStyle: .alert)
        controller.addAction(UIAlertAction(
            title: "Yes",
            style: .default)
                             {  (action) in
                                    let firebaseAuth = Auth.auth()
                                    do {
                                      try firebaseAuth.signOut()
                                    } catch let signOutError as NSError {
                                      print("Error signing out: %@", signOutError)
                                    }
                                    self.performSegue(withIdentifier: self.logoutSegueID, sender: nil)
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
