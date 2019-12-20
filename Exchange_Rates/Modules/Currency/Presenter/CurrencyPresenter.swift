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
        let session = URLSession.shared
        let url = URL(string: "https://openexchangerates.org/api/currencies.json?show_alternative=false")
        
        let task = session.dataTask(with: url!) { data, response, error in
            
            //Check for errors
            if error != nil {
                print(error?.localizedDescription ?? "No se pudo leer error")
                return
            }
            
            guard let httpCode = response as? HTTPURLResponse, (200...299).contains(httpCode.statusCode) else {
                print("Status code not successful")
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String: String] {
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
        
        task.resume()
    }
    
}
