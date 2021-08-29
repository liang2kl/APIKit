//
//  Query.swift
//  APIKit
//
//  Created by 梁业升 on 2021/8/27.
//  Copyright © 2021 梁业升. All rights reserved.
//

import Foundation

/// Protocol for query parameters.
public protocol QueryProtocol: ParameterProtocol {}
extension QueryProtocol {
    public var encoding: ParameterEncoding {
        URLEncoding.queryString
    }
}

/// Query parameters to be encoded into the url's query string
/// using url encoding.
@propertyWrapper
public struct Query<Value: Encodable>: QueryProtocol {
    /// The key of the query.
    public var key: String
    /// The value associated with the key.
    public var wrappedValue: Value?
    
    public init(wrappedValue: Value?, _ key: String) {
        self.key = key
        self.wrappedValue = wrappedValue
    }
    
    public func parameters() throws -> [String : Encodable] {
        guard !key.isEmpty else { throw RequestError.parameterError(.emptyKey) }
        guard let wrappedValue = wrappedValue else {
            return [:]
        }
        return [key: wrappedValue]
    }
}

/// A dictionary of query parameters to be encoded into the url's query string
/// using url encoding.
@propertyWrapper
public struct QueryDict<Value: Encodable>: QueryProtocol {
    /// The parameter dictionary.
    public var wrappedValue: [String : Encodable]?
    
    public init(wrappedValue: [String : Encodable]?) {
        self.wrappedValue = wrappedValue
    }
    
    public func parameters() throws -> [String : Encodable] {
        return wrappedValue ?? [:]
    }
}

/// A key to be presented in the query string with no value associated, using
/// url encoding.
@propertyWrapper
public struct KeyQuery: QueryProtocol {
    public var key: String
    /// Whether the key will be presented.
    public var wrappedValue: Bool
    
    public init(wrappedValue: Bool, _ key: String) {
        assert(!key.isEmpty)
        self.key = key
        self.wrappedValue = wrappedValue
    }
    
    public func parameters() throws -> [String : Encodable] {
        guard !key.isEmpty else { throw RequestError.parameterError(.emptyKey) }
        return [key: Optional<Int>.none]
    }
}
