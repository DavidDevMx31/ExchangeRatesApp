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
    
    func executeRequest(_ request: URLRequest, to endpoint: WebServiceEndpoints?) {
        let urlSession = URLSession.shared
        let task = urlSession.dataTask(with: request) { data, response, error in
            //Error
            if let responseError = error {
                print("La petición devolvió el siguiente error: \(responseError.localizedDescription)")
                self.delegate?.didReceiveError(error: responseError, errorMessage: nil, webService: endpoint)
                return
            }
            
            //Tipo HTTP
            guard let httpResponse = response as? HTTPURLResponse else {
                print("La respuesta no cumple con el protocolo HTTP")
                self.delegate?.didReceiveError(error: nil, errorMessage: "The response does not implements the HTTP Protocol", webService: endpoint)
                return
            }
            
            //Código HTTP
            if !(200...299).contains(httpResponse.statusCode) {
                if let responseData = data {
                    let message = self.decodeAPIError(data: responseData)
                    self.delegate?.didReceiveError(error: nil, errorMessage: message, webService: endpoint)
                } else {
                    self.delegate?.didReceiveError(error: nil, errorMessage: "The server responded with a status of \(httpResponse.statusCode)", webService: endpoint)
                }
                return
            }
    
            if let responseData = data {
                self.delegate?.didReceiveResponse(response: responseData, webService: endpoint)
            }
        }
        task.resume()
    }

    private func decodeAPIError(data: Data) -> String {
        let jsonDecoder = JSONDecoder()
        do {
            let decoded = try jsonDecoder.decode(APIErrorModel.self, from: data)
            return "Code: \(decoded.message).\n Description: \(decoded.description)"
        } catch {
            return "Unknown error"
        }
        
    }
}
