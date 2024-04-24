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
    @IBOutlet var numBreaksLabel: UIView!
    @IBOutlet weak var breakStatus: UILabel!
    
    @IBOutlet weak var pieChart: PieChartView!
    var date: Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // currDataLabel.text = "MM-DD-YYYY"
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        currDataLabel.text =  formatter.string(from: date)
        
        let dataEntries = [
            PieChartDataEntry(value: 30, label: "Task 1"),
            PieChartDataEntry(value: 20, label: "Task 2"),
            PieChartDataEntry(value: 50, label: "Task 3")
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
            
    }
    
    func colorWithHex(hex: Int, alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: alpha
        )
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
