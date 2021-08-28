//
//  HTTPMethod.swift
//  APIKit
//
//  Created by 梁业升 on 2021/8/27.
//  Copyright © 2021 梁业升. All rights reserved.
//  Ref: https://github.com/ishkawa/APIKit/blob/master/Sources/APIKit/HTTPMethod.swift
//

import Foundation

/// `HTTPMethod` represents HTTP methods.
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case head = "HEAD"
    case delete = "DELETE"
    case patch = "PATCH"
    case trace = "TRACE"
    case options = "OPTIONS"
    case connect = "CONNECT"
}
