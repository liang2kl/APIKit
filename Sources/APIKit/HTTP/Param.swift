//
//  Param.swift
//  APIKit
//
//  Created by 梁业升 on 2021/8/27.
//  Copyright © 2021 梁业升. All rights reserved.
//

import Foundation

public protocol ParameterProtocol {
    var encoding: ParameterEncoding { get }
    func parameters() -> [String : Encodable]
}

@propertyWrapper
public struct Param<Value: Encodable>: ParameterProtocol {
    var key: String
    public var wrappedValue: Value?
    
    public var encoding: ParameterEncoding { URLEncoding() }
    
    public init(wrappedValue: Value?, _ key: String) {
        assert(!key.isEmpty)
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
