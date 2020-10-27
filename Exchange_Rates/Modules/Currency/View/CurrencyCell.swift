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
    @IBOutlet weak var favoriteImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
        favoriteImage.isHidden = !isFavorite
    }
    
    func setupView() {
        baseLabel.textColor = .blue
        favoriteImage.image = UIImage(systemName: "star.fill")
        favoriteImage.tintColor = .yellow
        
        favoriteImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            favoriteImage.widthAnchor.constraint(equalTo: favoriteImage.heightAnchor)
        ])
    }
}
