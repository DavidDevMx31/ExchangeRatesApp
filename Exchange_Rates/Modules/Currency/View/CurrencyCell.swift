//
//  CurrencyCell.swift
//  Exchange_Rates
//
//  Created by David Ali on 27/12/19.
//  Copyright © 2019 David Mendoza. All rights reserved.
//

import UIKit

class CurrencyCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var baseLabel: UILabel!
    @IBOutlet weak var favoriteLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupView()
    }
    
    func fillCellData(name: String, isBase: Bool, isFavorite: Bool){
        nameLabel.text = name
        baseLabel.isHidden = !isBase
        favoriteLabel.isHidden = !isFavorite
    }
    
    func setupView() {
        baseLabel.textColor = .blue
        favoriteLabel.textColor = .green
    }
}
