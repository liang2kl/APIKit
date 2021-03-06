//
//  JSONDecodableRequest.swift
//  APIKit
//
//  Created by 梁业升 on 2021/8/27.
//  Copyright © 2021 梁业升. All rights reserved.
//

import Foundation

/// Protocol for request whose response data is in JSON format.
public protocol JSONDecodableRequest: Request where Response: Decodable, DataParser == JSONParser<Response> {
    var decoder: JSONDecoder { get }
}

public extension JSONDecodableRequest {
    var parser: JSONParser<Response> {
        return JSONParser(decoder: decoder)
    }
    
    var decoder: JSONDecoder {
        return JSONDecoder()
    }
}
