//
//  DataDisplayViewController.swift
//  GoTouchGrass
//
//  Created by Emely Diaz on 4/5/24.
//

import UIKit

class DataDisplayViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var monthLabel: UILabel!
    
    let dayIdentifier = "dayData"
    
    var selectedDate = Date()
    var totalSquares = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCellsView()
        setMonthView()
    }
    
    // comment
    func setCellsView() {
        let width = (collectionView.frame.size.width - 2) / 8
        let height = (collectionView.frame.size.height - 2) / 8
        
        let flowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: width, height: height)
    }
    
    // comment
    func setMonthView() {
        totalSquares.removeAll()
        
        let daysInMonth = CalendarHelper().daysInMonth(date: selectedDate)
        let firstDayOfMonth = CalendarHelper().firstOfMonth(date: selectedDate)
        let startingSpaces = CalendarHelper().weekDay(date: selectedDate)
        
        var count = 0
        
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
    
    // comment
    @IBAction func previousMonthPressed(_ sender: Any) {
        selectedDate = CalendarHelper().minusMonth(date: selectedDate)
        setMonthView()
    }
    
    // comment
    @IBAction func nextMonthPressed(_ sender: Any) {
        selectedDate = CalendarHelper().plusMonth(date: selectedDate)
        setMonthView()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        totalSquares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "calCell", for: indexPath) as! CalenderCell
        cell.dayOfMonth.text = totalSquares[indexPath.item]
        return cell
    }
    
 
    override open var shouldAutorotate: Bool {
        return false
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == dayIdentifier,
           let individualDayVC = segue.destination as? IndividualDayDataViewController {
            individualDayVC.date = selectedDate
        }
    }
    


}

