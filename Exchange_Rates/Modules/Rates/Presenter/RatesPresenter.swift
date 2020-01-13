//
//  RatesPresenter.swift
//  Exchange_Rates
//
//  Created by David Ali on 01/01/20.
//  Copyright © 2020 David Mendoza. All rights reserved.
//

import Foundation

protocol RatesProtocol {
    func fillBaseCurrencyData(code: String, name: String)
    func showRates()
    func noCurrencyCatalog()
    func noValidAmount()
}
class RatesPresenter {
    
    var view: RatesProtocol?
    var ratesCellArray = [RatesCellModel]()
    
    private var amount = 1.0 {
        didSet {
            recalculateRates()
        }
    }
    
    func attachView(view: RatesProtocol) {
        self.view = view
    }
    
    func detachView() {
        self.view = nil
    }
    
    func getBaseCurrencyData() {
        let baseCode = UserSettings.getBaseCurrencyCode()
        if let baseCurrency = RealmService.instance.realm.objects(CurrencyModel.self).filter("code == '\(baseCode)'").first {
            view?.fillBaseCurrencyData(code: baseCurrency.code, name: baseCurrency.name)
        } else {
            print("There are no currencies saved in Realm")
            view?.noCurrencyCatalog()
        }
    }
    
    func getRates() {
        if isRatesInfoReady() {
            getRatesFromRealm()
        } else {
            fetchRatesFromAPI()
        }
    }
    
    func refreshRatesData() {
        fetchRatesFromAPI()
    }
    
    private func isRatesInfoReady() -> Bool {
        let ratesExist = checkIfRatesExist()
        if !ratesExist { return false }
        
        let isSameBase = checkIfIsSameBase()
        if !isSameBase { return false }
        
        return true
    }
    
    private func checkIfRatesExist() -> Bool {
        if let _ = RealmService.instance.realm.objects(RatesModel.self).first {
            print("Hay tipos de cambio guardados")
            return true
        } else {
            print("No hay tipos de cambio guardados.")
            return false
        }
    }
    
    private func checkIfIsSameBase() -> Bool {
        let baseCode = UserSettings.getBaseCurrencyCode()
        
        if let _ = RealmService.instance.realm.objects(RatesModel.self).filter("currencyCode = '\(baseCode)'").first { return true } else { return false }
    }
    
    private func fetchRatesFromAPI() {
        print("Obteniendo tipos de cambio de la API...")
        
        let endpoint = WebServiceEndpoints.GetAllRates
        let url = URL(string: "?app_id=\(RatesConstants.appID)&show_alternative=true",
            relativeTo: URL(string: endpoint.rawValue))
        var request = URLRequest(url: url!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        print(url!.absoluteString)
        let ws = WebServiceCaller(delegate: self)
        ws.executeRequest(request: request, webService: endpoint)
    }
    
    private func getRatesFromRealm() {
        print("Obteniendo tipos de cambio locales...")
        
        let rates = RealmService.instance.realm.objects(RatesModel.self).sorted(byKeyPath: "currencyCode", ascending: true)
        let ratesArray = Array(rates)
        
        ratesCellArray.removeAll(keepingCapacity: true)
        
        for element in ratesArray {
            fillRatesCellModel(rates: element)
        }
        view?.showRates()
    }
    
    private func parseRatesModel(rates: RatesResponse) {
        DispatchQueue.main.async {
            let alternatives = UserSettings.getAlternativesCurrencies()
            
            var ratesArray = [RatesModel]()
            self.ratesCellArray.removeAll(keepingCapacity: true)
            
            for rate in rates.rates {
                let isAlternative = alternatives.contains(rate.key)
                if let currency = RealmService.instance.realm.objects(CurrencyModel.self).filter("code = '\(rate.key)'").first {
                    let element = RatesModel(value: ["base": UserSettings.getBaseCurrencyCode(),
                                                     "currencyCode" : currency.code,
                                                     "currencyName": currency.name,
                                                     "rate": rate.value,
                                                     "isAlternative": isAlternative])
                    ratesArray.append(element)
                    self.fillRatesCellModel(rates: element)
                } else {
                    print("No se encontró información para la moneda con código \(rate.key)")
                }
            }
            RealmService.instance.addArrayOfObjectsWithPK(ratesArray)
            self.sortRatesByCurrencyCodeAscending()
            self.view?.showRates()
        }
    }
    
    private func fillRatesCellModel(rates: RatesModel) {
        if !UserSettings.showAlternativeCurrencies() && rates.isAlternative { return }
        
        ratesCellArray.append(RatesCellModel(
            base: rates.base,
            currencyCode: rates.currencyCode,
            currencyName: rates.currencyName,
            rate: rates.rate,
            calculatedRate: calculateRate(baseRate: rates.rate, amount: amount)
        ))
    }
    
    private func calculateRate(baseRate: Double, amount: Double) -> Double {
        return baseRate * amount
    }
    
    func validateAmount(userAmount: String) {
        if let number = Double(userAmount) {
            amount = number
        } else {
            view?.noValidAmount()
        }
    }
    
    private func recalculateRates() {
        var newRates = [RatesCellModel]()
        for rate in ratesCellArray {
            newRates.append(RatesCellModel(base: rate.base,
                                           currencyCode: rate.currencyCode,
                                           currencyName: rate.currencyName,
                                           rate: rate.rate,
                                           calculatedRate: calculateRate(baseRate: rate.rate, amount: amount))
            )
        }
        ratesCellArray.removeAll(keepingCapacity: true)
        ratesCellArray = newRates
        sortRatesByCurrencyCodeAscending()
        view?.showRates()
    }
    
    private func sortRatesByCurrencyCodeAscending() {
        ratesCellArray.sort{ $0.currencyCode < $1.currencyCode }
    }
}

extension RatesPresenter: WebServiceCallerProtocol {
    func didReceiveResponse(response: Data, webService: WebServiceEndpoints?) {
        let decoder = JSONDecoder()
        do {
            let decoded = try decoder.decode(RatesResponse.self, from: response)
            parseRatesModel(rates: decoded)
        } catch {
            print("Failed to decode JSON")
        }
    }
    
    func didReceiveError(error: Error?, errorMessage: String?, webService: WebServiceEndpoints?) {
        print(errorMessage ?? "didReceiveError")
    }
}
