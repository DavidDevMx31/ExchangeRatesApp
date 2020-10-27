//
//  RatesTableViewModel.swift
//  Exchange_Rates
//
//  Created by David Ali on 14/01/20.
//  Copyright © 2020 David Mendoza. All rights reserved.
//

import Foundation

struct RatesTableViewModel {
    var section: [RatesSectionModel]
}

struct RatesSectionModel {
    var sectionName: String
    var rows: [RatesCellModel]
}
