//
//  Body.swift
//  APIKit
//
//  Created by 梁业升 on 2021/8/27.
//  Copyright © 2021 梁业升. All rights reserved.
//

import Foundation

public enum BodyEntity {
    case json(String)
    case urlEncoded([URLQueryItem])
}

public protocol BodyProtocol {
    var key: String { get set }
    var contentType: String { get }
    
    func entity() throws -> BodyEntity?
}

@propertyWrapper
public struct Body<Value: Encodable>: BodyProtocol {
    public let contentType: String = "application/json"
    
    var encoder: JSONEncoder = .init()
    public var key: String
    public var wrappedValue: Value?
    
    public init(wrappedValue: Value?, _ key: String, encoder: JSONEncoder = .init()) {
        assert(!key.isEmpty, "The key for the query cannot be empty.")
        self.wrappedValue = wrappedValue
        self.encoder = encoder
        self.key = key
    }
    
    public func entity() throws -> BodyEntity? {
        guard let wrappedValue = wrappedValue else {
            return nil
        }
        
        let dict = [key : wrappedValue]
        
        let data = try encoder.encode(dict)
        var string = String(data: data, encoding: .utf8)!
        while string.removeFirst() != "{" {}
        while string.removeLast() != "}" {}
        return .json(string)
    }
}

@propertyWrapper
public struct Field<Value: Encodable>: BodyProtocol {
    public let contentType: String = "application/x-www-form-urlencoded"
    
    public var key: String
    public var wrappedValue: Value?

    public init(wrappedValue: Value?, _ key: String) {
        assert(!key.isEmpty, "The key for the query cannot be empty.")
        self.wrappedValue = wrappedValue
        self.key = key
    }

    public func entity() throws -> BodyEntity? {
        guard let wrappedValue = wrappedValue else {
            return nil
        }

        let dict = [key : wrappedValue]
        return try .urlEncoded(URLQueryItemEncoder().encode(dict))
    }
}
