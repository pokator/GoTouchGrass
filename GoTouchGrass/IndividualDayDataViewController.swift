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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        currDataLabel.text =  formatter.string(from: date)
        
        let dataEntries = [
            PieChartDataEntry(value: 10, label: "ML assignment"),
            PieChartDataEntry(value: 40, label: "Final project IOS"),
            PieChartDataEntry(value: 50, label: "Studying for algo")
        ]
                
        let dataSet = PieChartDataSet(entries: dataEntries, label: "")
        dataSet.colors = [
            colorWithHex(hex: 7315838),
            colorWithHex(hex: 9357775),
            colorWithHex(hex: 16745312)
        ]
        
        let data = PieChartData(dataSet: dataSet)
        pieChart.data = data
        pieChart.holeRadiusPercent = 0.4
        pieChart.holeColor = colorWithHex(hex: 14805971)
        pieChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
            
        accesUser()
    }
    
    func colorWithHex(hex: Int, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }

    func accesUser() {
        var time = defaults.integer(forKey: "totalTime")
        currTotalTimeLabel.text = "\(time) seconds"
        totalTimeStatus.text = "The total focus time you have during this month: \(time) seconds"
        var breaks = defaults.integer(forKey: "numBreaks")
        numBreaksLabel.text = "Total # of breaks: \(breaks)"
        if breaks == 0 {
            breakStatus.text = "WOAH you need to take some breaks! You've done so much work! Go touch grass!"
        } else if breaks < 2 {
            breakStatus.text = "Come on you should take some more breaks! Make sure to stretch your legs!"
        } else {
            breakStatus.text = "You're doing AMAZING! Keep touching that grass!"
        }
        var taskCompleted = defaults.integer(forKey: "tasksCompleted")
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
