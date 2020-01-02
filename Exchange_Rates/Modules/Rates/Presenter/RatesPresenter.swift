//
//  RatesPresenter.swift
//  Exchange_Rates
//
//  Created by David Ali on 01/01/20.
//  Copyright © 2020 David Mendoza. All rights reserved.
//

import Foundation

protocol RatesProtocol {
    func showBaseCurrencyData(code: String, name: String)
    func noCurrencyCatalog()
}
class RatesPresenter {
    
    var view: RatesProtocol?
    
    func attachView(view: RatesProtocol) {
        self.view = view
    }
    
    func detachView() {
        self.view = nil
    }
    
    func getBaseCurrency() {
        let defaults = UserDefaults.standard
        let baseCurrencyCode = defaults.string(forKey: CurrencyKeys.base.rawValue) ?? CurrencyConstants.defaultBaseCurrency
        
        if let baseCurrency = RealmService.instance.realm.objects(CurrencyModel.self).filter("code == '\(baseCurrencyCode)'").first {
            view?.showBaseCurrencyData(code: baseCurrency.code, name: baseCurrency.name)
        } else {
            print("There are no currencies saved in Realm")
            view?.noCurrencyCatalog()
        }
    }
    
}
