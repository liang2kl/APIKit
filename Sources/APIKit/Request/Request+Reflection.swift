//
//  Request+Reflection.swift
//  APIKit
//
//  Created by 梁业升 on 2021/8/27.
//  Copyright © 2021 梁业升. All rights reserved.
//

import Foundation

extension Request {
    func inspectParameters(for request: URLRequest) throws -> URLRequest {
        let mirror = Mirror(reflecting: configuration)
        let prarmeters = mirror.children
            .map { $0.value }
            .compactMap { $0 as? ParameterProtocol }
        return try handleParameters(prarmeters, for: request)
    }
    
    func inspectHeaders(for request: URLRequest) throws -> URLRequest {
        let mirror = Mirror(reflecting: configuration)
        let headers = mirror.children
            .map { $0.value }
            .compactMap { $0 as? HeaderProtocol }
        return try handleHeaders(headers, for: request)
    }
    
}
