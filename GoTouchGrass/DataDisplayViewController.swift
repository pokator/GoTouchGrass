//
//  DataDisplayViewController.swift
//  GoTouchGrass
//
//  Created by Emely Diaz on 4/5/24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseFirestore
import Foundation

class DataDisplayViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var monthLabel: UILabel!
    
    let dayIdentifier = "dayData"

    var selectedDate = Date()
    var totalSquares = [String]()
    
    let db = Firestore.firestore()
    var completedTimers: [[String:Any]] = [[:]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCellsView()
        setMonthView()
    }
    
    // setiing the cells view to fix the collection view
    func setCellsView() {
        let width = (collectionView.frame.size.width - 2) / 8
        let height = (collectionView.frame.size.height - 2) / 8
        
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: width, height: height)
    }
    
    // set the month view based on when the first day of month is
    func setMonthView() {
        totalSquares.removeAll()
        
        let daysInMonth = CalendarHelper().daysInMonth(date: selectedDate)
        let firstDayOfMonth = CalendarHelper().firstOfMonth(date: selectedDate)
        let startingSpaces = CalendarHelper().weekDay(date: firstDayOfMonth)
        
        var count = 1
        while (count <= 42) {
            if (count <= startingSpaces || count - startingSpaces > daysInMonth) {
                totalSquares.append("")
            } else {
                totalSquares.append(String(count - startingSpaces))
            }
            count += 1
        }
        monthLabel.text = CalendarHelper().monthString(date: selectedDate)
        + " " + CalendarHelper().yearString(date: selectedDate)
        collectionView.reloadData()
    }
    
    // when the previous button is pressed changes the view
    @IBAction func previousMonthPressed(_ sender: Any) {
        selectedDate = CalendarHelper().minusMonth(date: selectedDate)
        setMonthView()
    }
    
    // when the next button is pressed changes the view
    @IBAction func nextMonthPressed(_ sender: Any) {
        selectedDate = CalendarHelper().plusMonth(date: selectedDate)
        setMonthView()
    }
    
    // count for all the cells in collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        totalSquares.count
    }
    
    // returns the cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calCell", for: indexPath) as! CalenderCell
        cell.dayOfMonth.text = totalSquares[indexPath.item]
        return cell
    }
    
    // activates when a cell is selected makes sure its a date cell, and that we have stored data for this day
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CalenderCell,
              let dayString = cell.dayOfMonth.text,
              let day = Int(dayString) else {
            return
        }
        
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month], from: selectedDate)
        dateComponents.day = day
        if let date = calendar.date(from: dateComponents) {
            // need to check if this date is in firebase
            selectedDate = date
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd-yyyy"
            let curDate = formatter.string(from: selectedDate)
            
            guard let uid = Auth.auth().currentUser?.uid else {
              return
            }
            
            let daysCollectionRef = db.collection("users").document(uid).collection("days")
            // Query all documents in the "days" subcollection
            daysCollectionRef.getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    // Iterate through the documents
                    var foundDocument: DocumentSnapshot?
                    for document in querySnapshot!.documents {
                        if let day = document.data()["day"] as? String, day == curDate {
                            // Found a document where "day" corresponds to the current day
                            foundDocument = document
                            break
                        }
                    }
                    // Check if a document was found
                    if let existingDocument = foundDocument {
                        // Document exists for the current day
                        print("Document exists for current day. ID: \(existingDocument.documentID)")
                        // Access the "timers" array if needed
                        if let timers = existingDocument.data()?["timers"] as? [[String:Any]]{
                            // read the timers
                            self.completedTimers = timers
                            self.performSegue(withIdentifier: self.dayIdentifier, sender: nil)
                        } else {
                            print("Timers array not found or not of expected type")
                        }
                    } else {
                        // Document doesn't exist for the current day, send an alert
                        let alertController = UIAlertController(title: "No Data", message: "You have no data for this day!", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default)
                        alertController.addAction(okAction)
                        // Present the alert controller
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
 
    // doesnt allow for suto rotate
    override open var shouldAutorotate: Bool {
        return false
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == dayIdentifier,
           let individualDayVC = segue.destination as? IndividualDayDataViewController {
            individualDayVC.date = selectedDate
            individualDayVC.dateCompletedTimers = completedTimers
        }
    }
}
