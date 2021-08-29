//
//  RequestError.swift
//  APIKit
//
//  Created by 梁业升 on 2021/8/27.
//  Copyright © 2021 梁业升. All rights reserved.
//

import Foundation

public enum RequestError: Error {
    case parameterError(ParameterErrorReason)
    case requestValidationError(RequestValidationErrorReason)
    case urlSessionError(Error)
    case parsingError(Error)
    case unknown
    
    public enum ParameterErrorReason {
        case invalidURL(String?)
        case encodeError(Error)
        case duplicateKey
        case mismatchedEncoding
        case unknown(Error)
    }
    
    public enum RequestValidationErrorReason {
        case bodyDataInGETRequest(Data)
    }
}

public enum ResponseError: Error {
    case unacceptableStatusCode(Int)
}
