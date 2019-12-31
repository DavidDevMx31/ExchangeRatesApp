//
//  WebServiceCallerProtocol.swift
//  Exchange_Rates
//
//  Created by David Ali on 20/12/19.
//  Copyright © 2019 David Mendoza. All rights reserved.
//

import Foundation

protocol WebServiceCallerProtocol {
    func didReceiveResponse(response: Data, webService: WebServiceEndpoints?)
    func didReceiveError(error: Error?, errorMessage: String?, webService: WebServiceEndpoints?)
}
