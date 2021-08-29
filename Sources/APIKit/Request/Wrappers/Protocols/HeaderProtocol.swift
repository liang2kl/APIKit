//
//  HeaderProtocol.swift
//  APIKit
//
//  Created by 梁业升 on 2021/8/27.
//  Copyright © 2021 梁业升. All rights reserved.
//

import Foundation

/// Protocol for a discoverable HTTP header type.
public protocol HeaderProtocol {
    /// Generates an HTTP header.
    func header() throws -> [String : String]
}
