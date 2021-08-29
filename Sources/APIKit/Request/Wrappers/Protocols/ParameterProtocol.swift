//
//  ParameterProtocol.swift
//  APIKit
//
//  Created by 梁业升 on 2021/8/27.
//  Copyright © 2021 梁业升. All rights reserved.
//

import Foundation

/// Protocol for a discoverable parameter type.
public protocol ParameterProtocol {
    /// The encoding used by the parameter.
    var encoding: ParameterEncoding { get }
    /// Generate parameters.
    func parameters() throws -> [String : Encodable]
}
