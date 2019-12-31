//
//  WebServiceEndpoints.swift
//  Exchange_Rates
//
//  Created by David Ali on 20/12/19.
//  Copyright © 2019 David Mendoza. All rights reserved.
//

import Foundation

enum WebServiceEndpoints: String {
    case GetAllCurrencies = "https://openexchangerates.org/api/currencies.json?show_alternative=true"
    case GetAlternativeCurrencies = "https://openexchangerates.org/api/currencies.json?only_alternative=true"
}
