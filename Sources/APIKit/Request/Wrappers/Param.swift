//
//  Param.swift
//  APIKit
//
//  Created by 梁业升 on 2021/8/27.
//  Copyright © 2021 梁业升. All rights reserved.
//

import Foundation

/// HTTP parameter with URL encoding.
///
/// Whether the parameter will be put into the query string or the body depends
/// on the request's http method.
@propertyWrapper
public struct Param<Value: Encodable>: ParameterProtocol {
    /// The key of the parameter.
    public var key: String
    /// The value associated with the key.
    public var wrappedValue: Value?

    public var encoding: ParameterEncoding { URLEncoding() }
    
    public init(wrappedValue: Value?, _ key: String) {
        self.wrappedValue = wrappedValue
        self.key = key
    }
    
    public func parameters() throws -> [String : Encodable] {
        guard !key.isEmpty else { throw RequestError.parameterError(.emptyKey) }
        guard let wrappedValue = wrappedValue else {
            return [:]
        }
        return [key: wrappedValue]
    }
}
