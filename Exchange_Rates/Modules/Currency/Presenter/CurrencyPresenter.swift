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
    private var favoriteCurrencies = [String]()
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
        getUserFavoriteCurrencies()
        getCurrenciesFromRealm()
        
        if currencies.count == 0 {
            fetchCurrenciesFromAPI()
        }
    }
    
    func refreshCurrenciesData() {
        fetchCurrenciesFromAPI()
    }
    
    func filterCurrenciesBy(currencyCode: String) {
        let filteredCurrencies = RealmService.instance.realm.objects(CurrencyModel.self).filter("code CONTAINS '\(currencyCode)' OR name CONTAINS '\(currencyCode)'").sorted(byKeyPath: "code", ascending: true)
        currencies = Array(filteredCurrencies)
    }
    
    func checkIfIsFavoriteCurrency(currencyCode: String) -> Bool {
        if favoriteCurrencies.contains(currencyCode) {
            return true
        }
        return false
    }
    
    func markOrUnmarkFavoriteBy(currencyCode: String) {
        if let index = favoriteCurrencies.firstIndex(of: currencyCode) {
            favoriteCurrencies.remove(at: index)
        } else {
            favoriteCurrencies.append(currencyCode)
        }
        
        saveUserFavoriteCurrencies()
    }
    
    private func getUserFavoriteCurrencies() {
        DispatchQueue.global().async { [weak self] in
            let defaults = UserDefaults.standard
            self?.favoriteCurrencies = defaults.array(forKey: CurrencyKeys.favorites.rawValue) as? [String] ?? [String]()
        }
    }
    
    private func getCurrenciesFromRealm() {
        let savedCurrencies = RealmService.instance.realm.objects(CurrencyModel.self).sorted(byKeyPath: "code", ascending: true)
        currencies = Array(savedCurrencies)
    }
    
    private func fetchCurrenciesFromAPI() {
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
    
    private func saveUserFavoriteCurrencies() {
        DispatchQueue.global().async { [weak self] in
            let defaults = UserDefaults.standard
            defaults.set(self?.favoriteCurrencies, forKey: CurrencyKeys.favorites.rawValue)
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
                                                     "isAlternative": false])
                response.append(currency)
            }
            self.saveCurrencies(currencies: response)
        }
    }

}
