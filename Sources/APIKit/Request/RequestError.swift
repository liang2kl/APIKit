//
//  RequestError.swift
//  APIKit
//
//  Created by 梁业升 on 2021/8/27.
//  Copyright © 2021 梁业升. All rights reserved.
//

import Foundation

public enum RequestError: Error {
    case parameterError(Error)
    case urlSessionError(Error)
    case parsingError(Error)
    case unknown
}

public enum ParameterError: Error {
    case invalidURL(String)
}

public enum ResponseError: Error {
    case unacceptableStatusCode(Int)
}
