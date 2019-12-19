//
//  SettingsConstants.swift
//  Exchange_Rates
//
//  Created by David Ali on 18/12/19.
//  Copyright © 2019 David Mendoza. All rights reserved.
//

import Foundation

enum UserSettingsKeys: String {
    case positions = "DecimalPositions"
    case saveDataMode = "SaveDataMode"
    case showAlternative = "ShowAlternative"
}

struct SettingsConstants {
    static let defaultDecimalPositions = 2
}
