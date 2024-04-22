//
//  RecommendationsViewController.swift
//  GoTouchGrass
//
//  Created by Kayla Han on 4/18/24.
//

import UIKit

class Recommendation {
    var name:String = "recName"
    var type:String = "typeName"
    var location:String = "locName"
}

var recList:[Recommendation] = []

class RecommendationsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var recommendationTableView: UITableView!
    
    
    let textCellIdentifier = "AddedRecommendation"
    
    override func viewDidLoad() {
            super.viewDidLoad()
            recommendationTableView.delegate = self
            recommendationTableView.dataSource = self

            // Do any additional setup after loading the view.
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return recList.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell:RecommendationTableViewCell = recommendationTableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath) as! RecommendationTableViewCell
            let row = indexPath.row
            cell.NameLabel.text = recList[row].name
            cell.LocationLabel.text = recList[row].location
            cell.TypeLabel.text = recList[row].type
            return cell
        }
        
        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if (editingStyle == .delete) {
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
