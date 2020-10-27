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
    case showAlternative = "ShowAlternative"
}

struct SettingsConstants {
    static let defaultDecimalPositions = 2
}

enum CurrencyKeys: String {
    case favorites = "favoriteCurrencies"
    case alternative = "alternativeCurrencies"
    case base = "baseCurrencyCode"
    case updateDate = "lastUpdate"
}

struct CurrencyConstants {
    static let defaultBaseCurrency = "USD"
}

struct RatesConstants {
    static let appID = "your-app-id"
}
