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
    func showError(errorMessage: String)
}

class CurrencyPresenter {
    private var view: CurrencyProtocol?
    var currencies = [CurrencyModel]()
    
    func attachView(view: CurrencyProtocol) {
        self.view = view
    }
    
    func detachView() {
        self.view = nil
    }
    
    func getCurrencies() {
        fetchAllCurrencies()
    }
    
    func fetchAllCurrencies() {
        let url = URL(string: WebServiceEndpoints.GetAllCurrencies.rawValue)
        var request = URLRequest(url: url!)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let ws = WebServiceCaller(delegate: self)
        ws.executeRequest(request: request)
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
            for element in json {
                let currency = CurrencyModel(code: element.key, name: element.value)
                self.currencies.append(currency)
            }
            
            self.currencies.sort {
                $0.code < $1.code
            }
            self.view?.showCurrencies()
        }
    }
}
