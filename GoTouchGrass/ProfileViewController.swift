//
//  ProfileViewController.swift
//  GoTouchGrass
//
//  Created by Kayla Han on 3/15/24.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    var username: String = ""
    let logoutSegueID = "logOutSegueIdentifier"
    @IBOutlet weak var dateUserCreated: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        username = Auth.auth().currentUser!.displayName ?? "Missing username"
        // print("User: ", username)
        // Do any additional setup after loading the view.
        usernameLabel.text = username
        
        if let creationDate = Auth.auth().currentUser?.metadata.creationDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy"
            let dataString = dateFormatter.string(from: creationDate)
            dateUserCreated.text = "User since: \(dataString)"
        } else {
            dateUserCreated.text = "Creation Date Unavaliable"
        }
        
        accesUser()
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
    
    func accesUser() {
        var time = defaults.integer(forKey: "totalTime")
        totalTimeLabel.text = "\(time) seconds"
    }
}
