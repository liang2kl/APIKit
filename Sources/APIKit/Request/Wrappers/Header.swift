//
//  Header.swift
//  APIKit
//
//  Created by 梁业升 on 2021/8/27.
//  Copyright © 2021 梁业升. All rights reserved.
//

import Foundation

/// An HTTP header.
@propertyWrapper
public struct Header: HeaderProtocol {
    /// The http field.
    public var field: String
    /// The value associated with the field.
    public var value: String?
    public var wrappedValue: String? {
        get { value }
        set { value = newValue }
    }
    
    public init(wrappedValue: String?, _ field: String) {
        self.value = wrappedValue
        self.field = field
    }
    
    public func header() throws -> [String : String] {
        guard !field.isEmpty else { throw RequestError.parameterError(.emptyKey) }
        guard let value = value else { return [:] }
        return [field : value]
    }
}

/// A dictionary of HTTP headers.
@propertyWrapper
public struct HeaderDict: HeaderProtocol {
    /// The dictionary of the headers.
    public var wrappedValue: [String : String]?
    
    public init(wrappedValue: [String : String]?) {
        self.wrappedValue = wrappedValue
    }
    
    public func header() -> [String : String] {
        return wrappedValue ?? [:]
    }
}
