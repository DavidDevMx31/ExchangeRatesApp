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
    func enteredInvalidAmount()
}
class RatesPresenter {
    
    var view: RatesProtocol?
    var fullRatesArray = RatesTableViewModel(section: [RatesSectionModel]())
    
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
            view?.noCurrencyCatalog()
        }
    }
    
    func getRates() {
        if isRatesInfoReady() {
            getLocalRatesData()
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
        return true
    }
    
    func validateAmount(userAmount: String) {
        if let number = Double(userAmount) {
            amount = number
        } else {
            view?.enteredInvalidAmount()
        }
    }
    
    private func recalculateRates() {
        var newValues = [RatesCellModel]()
        
        for index in 0..<fullRatesArray.section.count {
            
            for row in 0..<fullRatesArray.section[index].rows.count {
                let baseRate = fullRatesArray.section[index].rows[row]
                newValues.append(RatesCellModel(base: baseRate.base,
                                               currencyCode: baseRate.currencyCode,
                                               currencyName: baseRate.currencyName,
                                               rate: baseRate.rate,
                                               calculatedRate: calculateRate(baseRate: baseRate.rate, amount: amount))
                )
            }
            
            fullRatesArray.section[index].rows.removeAll(keepingCapacity: true)
            fullRatesArray.section[index].rows.append(contentsOf: newValues)
            newValues.removeAll()
        }
        view?.showRates()
    }
    
    private func calculateRate(baseRate: Double, amount: Double) -> Double {
        return baseRate * amount
    }
    
    //MARK: API
    
    private func fetchRatesFromAPI() {
        let endpoint = WebServiceEndpoints.GetAllRates
        let url = URL(string: "?app_id=\(RatesConstants.appID)&show_alternative=true",
            relativeTo: URL(string: endpoint.rawValue))
        var request = URLRequest(url: url!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        print(url!.absoluteString)
        let ws = WebServiceCaller(delegate: self)
        ws.executeRequest(request, to: endpoint)
    }
    
    //MARK: Realm
    
    private func checkIfRatesExist() -> Bool {
        if let _ = RealmService.instance.realm.objects(RatesModel.self).first {
            return true
        } else {
            return false
        }
    }
    
    private func getLocalRatesData() {
        let rates = RealmService.instance.realm.objects(RatesModel.self).sorted(byKeyPath: "currencyCode", ascending: true)
        let ratesArray = Array(rates)
        
        var ratesCellModel = [RatesCellModel]()
        
        for element in ratesArray {
            ratesCellModel.append(parseRatesToCellModel(rates: element))
        }
        fillTableViewModel(rates: ratesCellModel)
    }
    
    //MARK: Models parsing
    
    private func parseRatesResponse(rates: RatesResponse) {
        DispatchQueue.main.async { [weak self] in
            let alternatives = UserSettings.getAlternativesCurrencies()
            
            var ratesArray = [RatesModel]()
            
            for rate in rates.rates {
                let isAlternative = alternatives.contains(rate.key)
                if let currency = RealmService.instance.realm.objects(CurrencyModel.self).filter("code = '\(rate.key)'").first {
                    let element = RatesModel(value: ["base": UserSettings.getBaseCurrencyCode(),
                                                     "currencyCode" : currency.code,
                                                     "currencyName": currency.name,
                                                     "rate": rate.value,
                                                     "isAlternative": isAlternative])
                    ratesArray.append(element)
                } else {
                    print("No se encontró información para la moneda con código \(rate.key)")
                }
            }
            RealmService.instance.addArrayOfObjectsWithPK(ratesArray)
            self?.getLocalRatesData()
        }
    }
    
    private func fillTableViewModel(rates: [RatesCellModel]) {
        fullRatesArray.section.removeAll(keepingCapacity: true)
        fullRatesArray.section.append(RatesSectionModel(sectionName: "Favorites", rows: [RatesCellModel]()))
        fullRatesArray.section.append(RatesSectionModel(sectionName: "All", rows: [RatesCellModel]()))
        
        let favorites = UserSettings.getFavoriteCurrencies()
        
        if favorites.count == 0 {
            fullRatesArray.section[1].rows.append(contentsOf: rates)
        } else {
            for rate in rates {
                if favorites.contains(rate.currencyCode) {
                    fullRatesArray.section[0].rows.append(rate)
                } else {
                    fullRatesArray.section[1].rows.append(rate)
                }
            }
        }
        
        self.view?.showRates()
    }
    
    private func parseRatesToCellModel(rates: RatesModel) -> RatesCellModel {
         return RatesCellModel(
            base: rates.base,
            currencyCode: rates.currencyCode,
            currencyName: rates.currencyName,
            rate: rates.rate,
            calculatedRate: calculateRate(baseRate: rates.rate, amount: amount)
        )
    }
}

extension RatesPresenter: WebServiceCallerProtocol {
    func didReceiveResponse(response: Data, webService: WebServiceEndpoints?) {
        let decoder = JSONDecoder()
        do {
            let decoded = try decoder.decode(RatesResponse.self, from: response)
            UserSettings.saveRatesUpdateDate()
            parseRatesResponse(rates: decoded)
        } catch {
            print("Failed to decode JSON")
        }
    }
    
    func didReceiveError(error: Error?, errorMessage: String?, webService: WebServiceEndpoints?) {
        print(errorMessage ?? "didReceiveError")
    }
}
