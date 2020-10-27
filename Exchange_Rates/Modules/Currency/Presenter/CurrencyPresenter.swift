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
    private var baseCurrencyCode: String = ""
    
    func attachView(view: CurrencyProtocol) {
        self.view = view
    }
    
    func detachView() {
        self.view = nil
    }
    
    func loadData() {
        getUserBaseCurrency()
        getUserFavoriteCurrencies()
        getCurrencies()
    }
    
    private func getUserBaseCurrency() {
        self.baseCurrencyCode = UserSettings.getBaseCurrencyCode()
        print("Moneda base del usuario: \(baseCurrencyCode)")
    }
    
    private func getUserFavoriteCurrencies() {
        self.favoriteCurrencies = UserSettings.getFavoriteCurrencies()
    }
    
    func getCurrencies() {
        getCurrenciesFromRealm()
        
        if currencies.count == 0 {
            fetchAllCurrenciesFromAPI()
            fetchAlternativeCurrenciesFromAPI()
        }
    }
    
    func refreshCurrenciesData() {
        fetchAllCurrenciesFromAPI()
        fetchAlternativeCurrenciesFromAPI()
    }
    
    func checkIfIsFavoriteCurrency(currencyCode: String) -> Bool {
        return favoriteCurrencies.contains(currencyCode)
    }
    
    func checkIfIsBaseCurrency(currencyCode: String) -> Bool {
        return baseCurrencyCode == currencyCode
    }
    
    func manageFavoriteCurrency(currencyCode: String) {
        if let index = favoriteCurrencies.firstIndex(of: currencyCode) {
            favoriteCurrencies.remove(at: index)
        } else {
            favoriteCurrencies.append(currencyCode)
        }
        saveUserFavoriteCurrencies()
    }
    
    private func saveUserFavoriteCurrencies() {
        UserSettings.saveFavoriteCurrencies(self.favoriteCurrencies)
    }
    
    //MARK: API calls
    
    private func fetchAllCurrenciesFromAPI() {
        let endpoint = WebServiceEndpoints.GetAllCurrencies
        let url = URL(string: endpoint.rawValue)
        var request = URLRequest(url: url!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let ws = WebServiceCaller(delegate: self)
        ws.executeRequest(request, to: endpoint)
    }
    
    private func fetchAlternativeCurrenciesFromAPI() {
        let endpoint = WebServiceEndpoints.GetAlternativeCurrencies
        let url = URL(string: endpoint.rawValue)
        var request = URLRequest(url: url!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let ws = WebServiceCaller(delegate: self)
        ws.executeRequest(request, to: endpoint)
    }
    
    //MARK: Realm
    
    private func getCurrenciesFromRealm() {
        let savedCurrencies = RealmService.instance.realm.objects(CurrencyModel.self).sorted(byKeyPath: "code", ascending: true)
        currencies = Array(savedCurrencies)
    }
    
    private func saveCurrencies(currencies: [CurrencyModel]) {
        DispatchQueue.main.async {
            RealmService.instance.addArrayOfObjectsWithPK(currencies)
            self.getCurrenciesFromRealm()
        }
    }
    
    func filterCurrenciesBy(currencyCode: String) {
        let userFilter = currencyCode.uppercased()
        let filteredCurrencies = RealmService.instance.realm.objects(CurrencyModel.self).filter("code CONTAINS '\(userFilter)' OR name CONTAINS '\(userFilter)'").sorted(byKeyPath: "code", ascending: true)
        currencies = Array(filteredCurrencies)
    }
    
    //MARK: Fill data models
    private func fillAllCurrencies(data: [String: String]) {
        var allCurrencies = [CurrencyModel]()
        for element in data {
            let currency = CurrencyModel(value: ["code": element.key, "name": element.value, "isAlternative": false])
            allCurrencies.append(currency)
        }
        self.saveCurrencies(currencies: allCurrencies)
    }
    
    private func fillAlternativeCurrencies(data: [String: String]) {
        var alternativeCurrencies = [String]()
        for currency in data {
            alternativeCurrencies.append(currency.key)
        }
        UserSettings.saveAlternativeCurrencies(alternativeCurrencies)
    }
}

extension CurrencyPresenter: WebServiceCallerProtocol {
    
    func didReceiveError(error: Error?, errorMessage: String?, webService: WebServiceEndpoints?) {
        if let message = error {
            self.view?.showError(errorMessage: message.localizedDescription)
        } else if let message = errorMessage {
            self.view?.showError(errorMessage: message)
        }
    }
    
    func didReceiveResponse(response: Data, webService: WebServiceEndpoints?) {
        if let json = try? JSONSerialization.jsonObject(with: response, options: []) as? [String: String] {
            if let endpoint = webService {
                switch endpoint {
                case .GetAlternativeCurrencies:
                    fillAlternativeCurrencies(data: json)
                default:
                    fillAllCurrencies(data: json)
                }
            } else {
                print("No se indicó un endpoint al obtener la información de monedas. No se puede determinar qué flujo sigue.")
            }
        }
    }

}
