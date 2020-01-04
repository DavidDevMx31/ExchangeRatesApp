//
//  RatesResponse.swift
//  Exchange_Rates
//
//  Created by David Ali on 02/01/20.
//  Copyright © 2020 David Mendoza. All rights reserved.
//

import Foundation

struct RatesResponse: Codable {
    var disclaimer: String
    var license: String
    var base: String
    var rates: [String: Double]
}
