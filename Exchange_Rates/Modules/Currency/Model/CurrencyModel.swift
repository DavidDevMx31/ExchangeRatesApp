//
//  CurrencyModel.swift
//  Exchange_Rates
//
//  Created by David Ali on 18/12/19.
//  Copyright © 2019 David Mendoza. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class CurrencyModel: Object {
    dynamic var code: String = ""
    dynamic var name: String = ""
    dynamic var isAlternative: Bool = false
    
    override static func primaryKey() -> String? {
        return "code"
    }
}
