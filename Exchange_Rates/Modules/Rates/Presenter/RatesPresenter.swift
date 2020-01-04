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
    func showRates()
    func noCurrencyCatalog()
}
class RatesPresenter {
    
    var view: RatesProtocol?
    var ratesCellArray = [RatesCellModel]()
    
    func attachView(view: RatesProtocol) {
        self.view = view
    }
    
    func detachView() {
        self.view = nil
    }
    
    func getBaseCurrency() {
        let _ = checkRatesExist()
        let defaults = UserDefaults.standard
        let baseCurrencyCode = defaults.string(forKey: CurrencyKeys.base.rawValue) ?? CurrencyConstants.defaultBaseCurrency
        
        if let baseCurrency = RealmService.instance.realm.objects(CurrencyModel.self).filter("code == '\(baseCurrencyCode)'").first {
            view?.showBaseCurrencyData(code: baseCurrency.code, name: baseCurrency.name)
        } else {
            print("There are no currencies saved in Realm")
            view?.noCurrencyCatalog()
        }
    }
    
    private func checkRatesExist() -> Bool {
        if let _ = RealmService.instance.realm.objects(RatesModel.self).first {
            print("Hay tipos de cambio")
            getRatesFromRealm()
            return true
        } else {
            print("No hay tipos de cambio")
            fetchRatesFromAPI()
            return false
        }
    }
    
    private func checkSameBaseCurrency() -> Bool {
        let defaults = UserDefaults.standard
        let _ = defaults.string(forKey: CurrencyKeys.base.rawValue) ?? CurrencyConstants.defaultBaseCurrency
        
        return true
    }
    
    private func fetchRatesFromAPI() {
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
        let rates = RealmService.instance.realm.objects(RatesModel.self).sorted(byKeyPath: "currencyCode", ascending: true)
        let ratesArray = Array(rates)
        
        for element in ratesArray {
            fillRatesCellModel(rates: element)
        }
        view?.showRates()
    }
    
    private func fillRates(rates: RatesResponse) {
        DispatchQueue.main.async {
            let defaults = UserDefaults.standard
            let alternatives = defaults.object(forKey: CurrencyKeys.alternative.rawValue) as? [String] ?? [String]()
            
            var ratesArray = [RatesModel]()
            
            for rate in rates.rates {
                let isAlternative = alternatives.contains(rate.key)
                if let currency = RealmService.instance.realm.objects(CurrencyModel.self).filter("code = '\(rate.key)'").first {
                    let element = RatesModel(value: ["base": "USD",
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
            self.view?.showRates()
        }
    }
    
    private func fillRatesCellModel(rates: RatesModel) {
        let defaults = UserDefaults.standard
        var digits = defaults.integer(forKey: UserSettingsKeys.positions.rawValue)
        
        if digits == 0 {
            digits = SettingsConstants.defaultDecimalPositions
        }
        
        ratesCellArray.append(RatesCellModel(base: rates.base, currencyCode: rates.currencyCode, currencyName: rates.currencyName, rate: String(format: "%.2f", rates.rate), calculatedRate: String(format: "%.2f", rates.rate)))
    }
}

extension RatesPresenter: WebServiceCallerProtocol {
    func didReceiveResponse(response: Data, webService: WebServiceEndpoints?) {
        let decoder = JSONDecoder()
        do {
            let decoded = try decoder.decode(RatesResponse.self, from: response)
            fillRates(rates: decoded)
        } catch {
            print("Failed to decode JSON")
        }
    }
    
    func didReceiveError(error: Error?, errorMessage: String?, webService: WebServiceEndpoints?) {
        print(errorMessage ?? "didReceiveError")
    }
}
