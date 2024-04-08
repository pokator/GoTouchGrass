//
//  DatabaseViewController.swift
//  GoTouchGrass
//
//  Created by Kayla Han on 3/29/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class DatabaseViewController: UIViewController {

    
    @IBOutlet weak var dataLabel: UILabel!
    
    @IBOutlet weak var dataField: UITextField!
    
    @Published var newDataText: String = ""
    
    private lazy var databasePath: DatabaseReference? = {
      // 1
      guard let uid = Auth.auth().currentUser?.uid else {
        return nil
      }

      // 2
      let ref = Database.database()
        .reference()
        .child("users/\(uid)/preferences")
      return ref
    }()

    // 3
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        Auth.auth().signIn(withEmail: "test@gmail.com",
                           password: "test123"){
            (authResult, error) in
            if let error = error as NSError? {
                print("Unable to log in")
            } else {
                print("Logged in")
            }
        }
    }
    
    
    @IBAction func onWritePressed(_ sender: Any) {
        newDataText = (dataField.text ?? "")
        // 1
        guard let databasePath = databasePath else {
          return
        }

        // 2
        if newDataText.isEmpty {
          return
        }

        // 3
        let userPrefs = UserPrefsModel(username: "", prefFood: false, prefGym: false, prefRec: false, prefShop: false, timeDone:0, totalTime: 0, taskNum: 0, locRadius: 0.0)

        do {
          // 4
          let data = try encoder.encode(userPrefs)

          // 5
          let json = try JSONSerialization.jsonObject(with: data)

          // 6
          databasePath.childByAutoId()
            .setValue(json)
        } catch {
          print("an error occurred", error)
        }
    }
    
    
    @IBAction func onReadPressed(_ sender: Any) {
        // 1
        guard let databasePath = databasePath else {
          return
        }

        // 2
        databasePath
            .observe(.childAdded) { [weak self] snapshot,error  in

            // 3
            guard
              let self = self,
              var json = snapshot.value as? [String: Any]
            else {
              return
            }

            // 4
            json["id"] = snapshot.key

            do {

              // 5
              let thoughtData = try JSONSerialization.data(withJSONObject: json)
              // 6
              let prefs = try self.decoder.decode(UserPrefsModel.self, from: thoughtData)
              // 7
                self.dataLabel.text = prefs.username
            } catch {
              print("an error occurred", error)
            }
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
