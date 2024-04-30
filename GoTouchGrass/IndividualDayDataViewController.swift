//
//  IndividualDayDataViewController.swift
//  GoTouchGrass
//
//  Created by Emely Diaz on 4/6/24.
//

import UIKit
import Charts
import DGCharts

class IndividualDayDataViewController: UIViewController {

    @IBOutlet weak var currDataLabel: UILabel!
    @IBOutlet weak var currTotalTimeLabel: UILabel!
    @IBOutlet weak var totalTimeStatus: UILabel!
    @IBOutlet var numBreaksLabel: UILabel!
    @IBOutlet weak var breakStatus: UILabel!
    
    @IBOutlet weak var pieChart: PieChartView!
    var date: Date!
    var dateCompletedTimers: [[String:Any]]!
    var currTime = 0
    var dataEntries:[PieChartDataEntry] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        currDataLabel.text =  formatter.string(from: date)
        
        gettingData()
        currTotalTimeLabel.text = "\(currTime) seconds"
        
        let dataSet = PieChartDataSet(entries: dataEntries, label: "")
        dataSet.colors = [
            colorWithHex(hex: 7315838),
            colorWithHex(hex: 9357775),
            colorWithHex(hex: 16745312),
            colorWithHex(hex: 16036724),
            colorWithHex(hex: 15262344),
            colorWithHex(hex: 2392626),
            colorWithHex(hex: 863523)
        ]
        
        let data = PieChartData(dataSet: dataSet)
        pieChart.data = data
        pieChart.holeRadiusPercent = 0.4
        pieChart.holeColor = colorWithHex(hex: 14805971)
        pieChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
            
        accessUser()
    }
    
    // grabbing the users data for the current date selected
    func gettingData() {
        for timerMap in dateCompletedTimers {
            if let length = timerMap["length"] as? Int {
                currTime += length
            }
        }
        
        for timerMap in dateCompletedTimers {
            if let length = timerMap["length"] as? Int {
                if let tasks = timerMap["tasks"] as? [String] {
                    for task in tasks {
                        let value = (Double(length)/Double(currTime)) * 100.0
                        dataEntries.append(PieChartDataEntry(value: value, label: task))
                    }
                }
            }
        }
    }
    
    // helper method to get specific design colors
    func colorWithHex(hex: Int, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }

    // accessing the users defaults information
    func accessUser() {
        let time = defaults.integer(forKey: "totalTime")
        totalTimeStatus.text = "The total focus time you have during this month: \(time) seconds"
        let breaks = defaults.integer(forKey: "numBreaks")
        numBreaksLabel.text = "Total # of breaks: \(breaks)"
        if breaks == 0 {
            breakStatus.text = "WOAH you need to take some breaks! You've done so much work! Go touch grass!"
        } else if breaks < 3 {
            breakStatus.text = "Come on you should take some more breaks! Make sure to stretch your legs!"
        } else {
            breakStatus.text = "You're doing AMAZING! Keep touching that grass!"
        }
    }
}
