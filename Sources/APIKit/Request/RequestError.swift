//
//  RequestError.swift
//  APIKit
//
//  Created by 梁业升 on 2021/8/27.
//  Copyright © 2021 梁业升. All rights reserved.
//

import Foundation

public enum RequestError: Error {
    /// Error occured when processing given parameters.
    case parameterError(ParameterErrorReason)
    /// The request object is invalid.
    case requestValidationError(RequestValidationErrorReason)
    /// Error occured during the session.
    case urlSessionError(Error)
    /// Error occured when parsing response data.
    case parsingError(Error)
    /// Unknown error.
    case unknown
    
    public enum ParameterErrorReason {
        /// The request URL string is invalid.
        case invalidURL(String?)
        /// Fail to encode the parameters.
        case encodeError(Error)
        /// The configuration contains duplicate keys.
        case duplicateKey
        /// The key of the paramter or header is empty.
        case emptyKey
        /// The encoding of the parameters does not match.
        case mismatchedEncoding
        /// Other uncatagorized error.
        case other(Error)
    }
    
    public enum RequestValidationErrorReason {
        /// Unexpectedly found body data in a `GET` request.
        case bodyDataInGETRequest(Data)
    }
}

public enum ResponseError: Error {
    /// The response has unacceptable status code.
    case unacceptableStatusCode(Int)
}
