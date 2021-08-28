//
//  Query.swift
//  APIKit
//
//  Created by 梁业升 on 2021/8/27.
//  Copyright © 2021 梁业升. All rights reserved.
//

import Foundation

public protocol QueryProtocol {
    func queryItems() throws -> [URLQueryItem]
}

@propertyWrapper
public struct Query<Value: Encodable>: QueryProtocol {
    var key: String
    public var wrappedValue: Value?

    public func queryItems() throws -> [URLQueryItem] {
        // FIXME
        guard !key.isEmpty else { throw QueryError.invalidKey }
        guard wrappedValue != nil else { return [] }
        let dict = [key : wrappedValue]
        return try URLQueryItemEncoder().encode(dict)
    }
    
    public init(wrappedValue: Value?, _ key: String) {
        assert(!key.isEmpty, "The key for the query cannot be empty.")
        self.key = key
        self.wrappedValue = wrappedValue
    }
    
    public enum Error: Swift.Error {
        case invalidKey
    }
}

@propertyWrapper
public struct QueryDict<Value: Encodable>: QueryProtocol {
    public var wrappedValue: [String : Value]?
    
    public func queryItems() throws -> [URLQueryItem] {
        guard let wrappedValue = wrappedValue else { return [] }

        return try URLQueryItemEncoder().encode(wrappedValue)
    }
    
    public init(wrappedValue: [String : Value]?) {
        self.wrappedValue = wrappedValue
    }
}

@propertyWrapper
public struct KeyQuery: QueryProtocol {
    var key: String
    public var wrappedValue: Bool
    
    public func queryItems() throws -> [URLQueryItem] {
        guard !key.isEmpty else { throw QueryError.invalidKey }
        if !wrappedValue { return [] }
        let dict = [wrappedValue : Optional<Int>.none]
        return try URLQueryItemEncoder().encode(dict)
    }
    
    public init(wrappedValue: Bool, _ key: String) {
        self.key = key
        self.wrappedValue = wrappedValue
    }
}

public enum QueryError: Swift.Error {
    case invalidKey
}
