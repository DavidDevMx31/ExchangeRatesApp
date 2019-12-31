//
//  WebServiceCaller.swift
//  Exchange_Rates
//
//  Created by David Ali on 20/12/19.
//  Copyright © 2019 David Mendoza. All rights reserved.
//

import Foundation

class WebServiceCaller {
    
    let delegate: WebServiceCallerProtocol?
    
    init(delegate: WebServiceCallerProtocol) {
        self.delegate = delegate
    }
    
    func executeRequest(request: URLRequest, webService: WebServiceEndpoints?) {
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { data, response, error in
            
            //Error
            if let responseError = error {
                print(responseError.localizedDescription)
                self.delegate?.didReceiveError(error: responseError, errorMessage: nil, webService: webService)
                return
            }
            
            //Tipo HTTP
            guard let httpResponse = response as? HTTPURLResponse else {
                print("La respuesta no cumple con el protocolo HTTP")
                self.delegate?.didReceiveError(error: nil, errorMessage: "The response does not implements the HTTP Protocol", webService: webService)
                return
            }
            
            //Código HTTP
            if !(200...299).contains(httpResponse.statusCode) {
                self.delegate?.didReceiveError(error: nil, errorMessage: "The server responded with a status of \(httpResponse.statusCode)", webService: webService)
                return
            }
    
            if let responseData = data {
                self.delegate?.didReceiveResponse(response: responseData, webService: webService)
            }
        }
        task.resume()
        
    }

}
