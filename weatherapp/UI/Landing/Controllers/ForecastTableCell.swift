//
//  ForecastTableCell.swift
//  weatherapp
//
//  Created by Bourne Koloh on 02/08/2023.
//

import UIKit

class ForecastTableCell:UITableViewCell {
    
    
    @IBOutlet weak var DayLabel: UILabel!
    @IBOutlet weak var TempLabel: UILabel!
    @IBOutlet weak var WeatherIcon: UIImageView!
    
    func clearCellData(){
        //
        self.DayLabel.text = ""
        self.TempLabel.text = ""
        self.WeatherIcon.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        //
        clearCellData()
        
    }
}
