//
//  RatesModel.swift
//  Exchange_Rates
//
//  Created by David Ali on 02/01/20.
//  Copyright © 2020 David Mendoza. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class RatesModel: Object {
    dynamic var base: String = ""
    dynamic var currencyCode: String = ""
    dynamic var currencyName: String = ""
    dynamic var rate: Double = 0.0
    dynamic var isAlternative: Bool = false
    
    override static func primaryKey() -> String? {
        return "currencyCode"
    }
}
