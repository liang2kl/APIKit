//
//  Body.swift
//  APIKit
//
//  Created by 梁业升 on 2021/8/27.
//  Copyright © 2021 梁业升. All rights reserved.
//

import Foundation

@propertyWrapper
public struct JSON<Value: Encodable>: ParameterProtocol {
    public var key: String
    public var wrappedValue: Value?
    
    public var encoding: ParameterEncoding {
        JSONEncoding.default
    }
    
    public init(wrappedValue: Value?, _ key: String) {
        assert(!key.isEmpty, "The key for the query cannot be empty.")
        self.wrappedValue = wrappedValue
        self.key = key
    }
    
    public func parameters() -> [String : Encodable] {
        guard let wrappedValue = wrappedValue else {
            return [:]
        }
        return [key: wrappedValue]
    }
}

@propertyWrapper
public struct Field<Value: Encodable>: ParameterProtocol {
    public var key: String
    public var wrappedValue: Value?
    
    public var encoding: ParameterEncoding {
        return URLEncoding.httpBody
    }

    public init(wrappedValue: Value?, _ key: String) {
        assert(!key.isEmpty, "The key for the query cannot be empty.")
        self.wrappedValue = wrappedValue
        self.key = key
    }

    public func parameters() -> [String : Encodable] {
        guard let wrappedValue = wrappedValue else {
            return [:]
        }
        return [key: wrappedValue]
    }
}
