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
    
    func fillCellData(rate: Double, currency: CurrencyModel, equivalence: Double){
        ratesLabel.text = "\(rate) \(currency.code)"
        currencyLabel.text = "\(currency.code) - \(currency.name)"
        equivalenceLabel.text = "1 MXN = \(equivalence) \(currency.code)"
    }
}
