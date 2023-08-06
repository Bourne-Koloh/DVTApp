//
//  EmptyTableCell.swift
//  weatherapp
//
//  Created by Bourne Koloh on 02/08/2023.
//

import UIKit

class EmptyTableCell:UITableViewCell {
    @IBOutlet weak var CaptionLabel: UILabel!
    
    func clearCellData(){
        //
        self.CaptionLabel.text = ""
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        //
        clearCellData()
        
    }
}
