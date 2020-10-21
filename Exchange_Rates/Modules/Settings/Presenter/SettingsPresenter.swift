//
//  SettingsPresenter.swift
//  Exchange_Rates
//
//  Created by David Ali on 18/12/19.
//  Copyright © 2019 David Mendoza. All rights reserved.
//

import Foundation

protocol SettingsProtocol {
    func showUserSettings(defaults: SettingsModel)
}

struct SettingsPresenter {
    var view: SettingsProtocol?
    
    init(view: SettingsProtocol) {
        self.view = view
    }
    
    func saveSettings(decimalPositions: Int, saveData: Bool, showAlternativeCurrencies: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(decimalPositions, forKey: UserSettingsKeys.positions.rawValue)
        defaults.set(saveData, forKey: UserSettingsKeys.saveDataMode.rawValue)
        defaults.set(showAlternativeCurrencies, forKey: UserSettingsKeys.showAlternative.rawValue)
    }
    
    func getUserSettings() {
        let defaults = UserDefaults.standard
        
        var positions = defaults.integer(forKey: UserSettingsKeys.positions.rawValue)
        let saveDataMode = defaults.bool(forKey: UserSettingsKeys.saveDataMode.rawValue)
        let showAlternative = defaults.bool(forKey: UserSettingsKeys.showAlternative.rawValue)
        
        if positions == 0 {
            positions = SettingsConstants.defaultDecimalPositions
        }
        
        let settings = SettingsModel(decimalPositions: positions, saveData: saveDataMode, showAlternativeCurrencies: showAlternative)
        
        view?.showUserSettings(defaults: settings)
    }
}
