//
//  CurrencyPresenter.swift
//  Exchange_Rates
//
//  Created by David Ali on 18/12/19.
//  Copyright © 2019 David Mendoza. All rights reserved.
//

import Foundation

protocol CurrencyProtocol {
    func showCurrencies()
}

class CurrencyPresenter {
    private var view: CurrencyProtocol?
    var currencies = [CurrencyModel]()
    
    init(view: CurrencyProtocol) {
        self.view = view
    }
    
    func getCurrencies() {
        for i in 0..<5 {
            currencies.append(CurrencyModel(code: "Code \(i)", name: "Currency \(i)"))
        }

        view?.showCurrencies()
    }
    
}
