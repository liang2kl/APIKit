//
//  JSONDecodableRequest.swift
//  APIKit
//
//  Created by 梁业升 on 2021/8/27.
//  Copyright © 2021 梁业升. All rights reserved.
//

import Foundation

protocol JSONDecodableRequest: Request where Response: Decodable, DataParser == JSONParser<Response> {
    var decoder: JSONDecoder { get }
}

extension JSONDecodableRequest {
    var parser: JSONParser<Response> {
        return JSONParser(decoder: decoder)
    }
}
