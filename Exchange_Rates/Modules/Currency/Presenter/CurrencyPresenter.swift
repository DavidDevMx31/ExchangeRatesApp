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
    
    func getCurrencies() {
        getUserBaseCurrency()
        getUserFavoriteCurrencies()
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
    
    func filterCurrenciesBy(currencyCode: String) {
        let userFilter = currencyCode.uppercased()
        let filteredCurrencies = RealmService.instance.realm.objects(CurrencyModel.self).filter("code CONTAINS '\(userFilter)' OR name CONTAINS '\(userFilter)'").sorted(byKeyPath: "code", ascending: true)
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
    
    func checkIfIsBaseCurrency(currencyCode: String) -> Bool {
        if baseCurrencyCode == currencyCode {
            return true
        }
        
        return false
    }
    
    func setBaseCurrency(currencyCode: String) {
        baseCurrencyCode = currencyCode
        DispatchQueue.global().async {
            print("Guardando moneda base: \(currencyCode)")
            let defaults = UserDefaults.standard
            defaults.set(currencyCode, forKey: CurrencyKeys.base.rawValue)
        }
    }
    
    private func getUserFavoriteCurrencies() {
        if favoriteCurrencies.count != 0 { return }
        
        DispatchQueue.global().async { [weak self] in
            let defaults = UserDefaults.standard
            self?.favoriteCurrencies = defaults.array(forKey: CurrencyKeys.favorites.rawValue) as? [String] ?? [String]()
        }
    }
    
    private func getCurrenciesFromRealm() {
        let savedCurrencies = RealmService.instance.realm.objects(CurrencyModel.self).sorted(byKeyPath: "code", ascending: true)
        currencies = Array(savedCurrencies)
    }
    
    private func fetchAllCurrenciesFromAPI() {
        print("Obteniendo todas las monedas")
        let endpoint = WebServiceEndpoints.GetAllCurrencies
        let url = URL(string: endpoint.rawValue)
        var request = URLRequest(url: url!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let ws = WebServiceCaller(delegate: self)
        ws.executeRequest(request: request, webService: endpoint)
    }
    
    private func fetchAlternativeCurrenciesFromAPI() {
        print("Obteniendo las monedas alternativas")
        let endpoint = WebServiceEndpoints.GetAlternativeCurrencies
        let url = URL(string: endpoint.rawValue)
        var request = URLRequest(url: url!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let ws = WebServiceCaller(delegate: self)
        ws.executeRequest(request: request, webService: endpoint)
    }
    
    private func saveCurrencies(currencies: [CurrencyModel]) {
        DispatchQueue.main.async {
            RealmService.instance.addArrayOfObjectsWithPK(currencies)
            self.getCurrenciesFromRealm()
        }
    }
    
    private func saveUserFavoriteCurrencies() {
        self.saveArrayToDefaults(dataArray: self.favoriteCurrencies, keyName: CurrencyKeys.favorites.rawValue)
    }
    
    private func fillAllCurrencies(data: [String: String]) {
        var allCurrencies = [CurrencyModel]()
        for element in data {
            let currency = CurrencyModel(value: ["code": element.key,
                                                 "name": element.value,
                                                 "isAlternative": false])
            allCurrencies.append(currency)
        }
        self.saveCurrencies(currencies: allCurrencies)
    }
    
    private func fillAlternativeCurrencies(data: [String: String]) {
        var alternativeCurrencies = [String]()
        for currency in data {
            alternativeCurrencies.append(currency.key)
        }
        saveArrayToDefaults(dataArray: alternativeCurrencies, keyName: CurrencyKeys.alternative.rawValue)
    }
    
    private func saveArrayToDefaults(dataArray: [String], keyName: String) {
        DispatchQueue.global().async {
            //print("Guardando datos de: \(keyName)")
            let defaults = UserDefaults.standard
            defaults.set(dataArray, forKey: keyName)
        }
    }
    
    private func getUserBaseCurrency() {
        if baseCurrencyCode != "" { return }
        DispatchQueue.global().async {
            print("Obteniendo moneda base")
            let defaults = UserDefaults.standard
            if let baseCode = defaults.string(forKey: CurrencyKeys.base.rawValue) {
                self.baseCurrencyCode = baseCode
                print("Base usuario: \(baseCode)")
            }
        }
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
