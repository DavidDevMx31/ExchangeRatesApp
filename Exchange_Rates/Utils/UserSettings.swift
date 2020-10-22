//
//  UserSettings.swift
//  Exchange_Rates
//
//  Created by David Ali on 04/01/20.
//  Copyright © 2020 David Mendoza. All rights reserved.
//

import Foundation

struct UserSettings {
    private static let defaults = UserDefaults.standard
    
    static func getBaseCurrencyCode() -> String {
        return defaults.string(forKey: CurrencyKeys.base.rawValue) ?? CurrencyConstants.defaultBaseCurrency
    }
    
    static func getNumberOfDecimals() -> Int {
        let numberOfDecimals = defaults.integer(forKey: UserSettingsKeys.positions.rawValue)
        
        if numberOfDecimals == 0 {
            return SettingsConstants.defaultDecimalPositions
        }
        
        return numberOfDecimals
    }
    
    static func showAlternativeCurrencies() -> Bool {
        return defaults.bool(forKey: UserSettingsKeys.showAlternative.rawValue) 
    }
    
    static func getAlternativesCurrencies() -> [String] {
        return defaults.object(forKey: CurrencyKeys.alternative.rawValue) as? [String] ?? [String]()
    }
    
    static func getFavoriteCurrencies() -> [String] {
        return defaults.object(forKey: CurrencyKeys.favorites.rawValue) as? [String] ?? [String]()
    }
}
