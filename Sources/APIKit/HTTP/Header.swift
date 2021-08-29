//
//  Header.swift
//  APIKit
//
//  Created by 梁业升 on 2021/8/27.
//  Copyright © 2021 梁业升. All rights reserved.
//

import Foundation

public protocol HeaderProtocol {
    func header() -> [String : String]
}

@propertyWrapper
public struct Header: HeaderProtocol {
    var field: String
    var value: String?
    public var wrappedValue: String? {
        get { value }
        set { value = newValue }
    }
    
    public init(wrappedValue: String?, _ field: String) {
        assert(!field.isEmpty, "Header field cannot be empty")
        self.value = wrappedValue
        self.field = field
    }
    
    public func header() -> [String : String] {
        guard let value = value else { return [:] }
        return [field : value]
    }
}

@propertyWrapper
public struct HeaderDict: HeaderProtocol {
    public var wrappedValue: [String : String]?
    
    public init(wrappedValue: [String : String]?) {
        self.wrappedValue = wrappedValue
    }
    
    public func header() -> [String : String] {
        return wrappedValue ?? [:]
    }
}
