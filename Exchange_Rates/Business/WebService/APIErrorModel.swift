//
//  APIErrorModel.swift
//  Exchange_Rates
//
//  Created by David Ali on 27/10/20.
//  Copyright © 2020 David Mendoza. All rights reserved.
//

import Foundation

struct APIErrorModel : Decodable {
    let error: Bool
    let status: Int
    let message: String
    let description: String
}
