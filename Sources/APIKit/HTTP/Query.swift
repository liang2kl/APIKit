//
//  Query.swift
//  APIKit
//
//  Created by 梁业升 on 2021/8/27.
//  Copyright © 2021 梁业升. All rights reserved.
//

import Foundation

public protocol QueryProtocol: ParameterProtocol {}
extension QueryProtocol {
    public var encoding: ParameterEncoding {
        URLEncoding.queryString
    }
}

@propertyWrapper
public struct Query<Value: Encodable>: QueryProtocol {
    var key: String
    public var wrappedValue: Value?
    
    public init(wrappedValue: Value?, _ key: String) {
        assert(!key.isEmpty, "The key for the query cannot be empty.")
        self.key = key
        self.wrappedValue = wrappedValue
    }
    
    public func parameters() -> [String : Encodable] {
        guard let wrappedValue = wrappedValue else {
            return [:]
        }
        return [key: wrappedValue]
    }
}

@propertyWrapper
public struct QueryDict<Value: Encodable>: QueryProtocol {
    public var wrappedValue: [String : Encodable]?
    
    public init(wrappedValue: [String : Encodable]?) {
        self.wrappedValue = wrappedValue
    }
    
    public func parameters() -> [String : Encodable] {
        return wrappedValue ?? [:]
    }
}

@propertyWrapper
public struct KeyQuery: QueryProtocol {
    var key: String
    public var wrappedValue: Bool
    
    public init(wrappedValue: Bool, _ key: String) {
        assert(!key.isEmpty)
        self.key = key
        self.wrappedValue = wrappedValue
    }
    
    public func parameters() -> [String : Encodable] {
        // FIXME: Emtpy?
        return [key: Optional<Int>.none]
    }
}
