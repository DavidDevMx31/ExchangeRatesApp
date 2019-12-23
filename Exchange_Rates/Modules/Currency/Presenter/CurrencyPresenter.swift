//
//  CurrencyPresenter.swift
//  Exchange_Rates
//
//  Created by David Ali on 18/12/19.
//  Copyright © 2019 David Mendoza. All rights reserved.
//

import Foundation
import RealmSwift

protocol CurrencyProtocol {
    func showCurrencies()
    func showError(errorMessage: String)
}

class CurrencyPresenter {
    private var view: CurrencyProtocol?
    var currencies = [CurrencyModel]() {
        didSet {
            view?.showCurrencies()
        }
    }
    
    func attachView(view: CurrencyProtocol) {
        self.view = view
    }
    
    func detachView() {
        self.view = nil
    }
    
    func getCurrencies() {
        getCurrenciesFromRealm()
        
        if currencies.count == 0 {
            fetchCurrenciesFromAPI()
        }
    }
    
    func refreshCurrenciesData() {
        fetchCurrenciesFromAPI()
    }
    
    func filterCurrenciesBy(code: String) {
        let filteredCurrencies = RealmService.instance.realm.objects(CurrencyModel.self).filter("code CONTAINS '\(code)' OR name CONTAINS '\(code)'").sorted(byKeyPath: "code", ascending: true)
        currencies = Array(filteredCurrencies)
    }
    
    private func getCurrenciesFromRealm() {
        print("Obteniendo datos locales")
        let savedCurrencies = RealmService.instance.realm.objects(CurrencyModel.self).sorted(byKeyPath: "code", ascending: true)
        currencies = Array(savedCurrencies)
    }
    
    
    private func fetchCurrenciesFromAPI() {
        print("Obteniendo datos API")
        let url = URL(string: WebServiceEndpoints.GetAllCurrencies.rawValue)
        var request = URLRequest(url: url!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let ws = WebServiceCaller(delegate: self)
        ws.executeRequest(request: request)
    }
    
    private func saveCurrencies(currencies: [CurrencyModel]) {
        DispatchQueue.main.async {
            RealmService.instance.addArrayOfObjectsWithPK(currencies)
            self.getCurrenciesFromRealm()
        }
    }
    
}

extension CurrencyPresenter: WebServiceCallerProtocol {
    
    func didReceiveError(error: Error?, errorMessage: String?) {
        if let message = error {
            self.view?.showError(errorMessage: message.localizedDescription)
        } else if let message = errorMessage {
            self.view?.showError(errorMessage: message)
        }
    }
    
    func didReceiveResponse(response: Data) {
        if let json = try? JSONSerialization.jsonObject(with: response, options: []) as? [String: String] {
            var response = [CurrencyModel]()
            for element in json {
                let currency = CurrencyModel(value: ["code": element.key,
                                                     "name": element.value,
                                                     "isFavorite": false,
                                                     "isAlternative": false])
                response.append(currency)
            }
            self.saveCurrencies(currencies: response)
        }
    }

}
