//
//  Header.swift
//  APIKit
//
//  Created by 梁业升 on 2021/8/27.
//  Copyright © 2021 梁业升. All rights reserved.
//

import Foundation

@propertyWrapper
public struct Header {
    var field: String
    var value: String
    public var wrappedValue: String {
        get { value }
        set { value = newValue }
    }
    
    public init(wrappedValue: String, _ field: String) {
        self.value = wrappedValue
        self.field = field
    }
}
