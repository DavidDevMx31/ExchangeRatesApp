//
//  RatesCell.swift
//  Exchange_Rates
//
//  Created by David Ali on 02/01/20.
//  Copyright © 2020 David Mendoza. All rights reserved.
//

import UIKit

class RatesCell: UITableViewCell {

    @IBOutlet weak var ratesLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var equivalenceLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        setupCell()
    }
    
    private func setupCell() {
        
    }
    
    func fillCellData(baseRate: Double, totalRate: Double, currencyCode: String, currencyName: String, baseCode: String){
        ratesLabel.text = "\(formatDouble(number: totalRate)) \(currencyCode)"
        currencyLabel.text = "\(currencyCode) - \(currencyName)"
        equivalenceLabel.text = "1.0 \(baseCode) = \(formatDouble(number: baseRate)) \(currencyCode)"
    }
    
    private func formatDouble(number: Double) -> String {
        let numberOfDecimals = UserSettings.getNumberOfDecimals()
        return String(format: "%.\(numberOfDecimals)f", number)
    }
}
