//
//  Request.swift
//  APIKit
//
//  Created by 梁业升 on 2021/8/27.
//  Copyright © 2021 梁业升. All rights reserved.
//

import Foundation

/// Abstraction for an HTTP request.
///
/// The following items must be implemented:
/// - `associatedtype Response`
/// - `var base: URL`
/// - `var path: String`
/// - `var method: HTTPMethod`
/// - `var configuration: Configuration`
/// - `var parser: DataParser`
public protocol Request {
    /// Type for the configuration object that the request uses. Must conform to
    /// `RequestConfiguration`.
    associatedtype Configuration: RequestConfiguration
    
    /// Type for the final data produced by the request.
    associatedtype Response
    
    /// The data parser that parse the response data into `Response`.
    associatedtype DataParser: Parser where DataParser.Object == Response
    
    /// The base url of the request.
    var base: URL { get }
    
    /// The path for the request.
    var path: String { get }
    
    /// The HTTP method used by the request.
    var method: HTTPMethod { get }
    
    /// The configuration object that the request used to handle headers and
    /// parameters.
    ///
    /// For convenience, the request itself can be its configuration.
    /// For example:
    ///
    /// ```swift
    /// struct MyRequest: Request {
    ///     @Header("TOKEN") var token = nil
    ///     @Query("page") var page: Int = nil
    ///
    ///     var configuration: Self { return self }
    /// }
    /// ```
    var configuration: Configuration { get }
    
    /// The parser used to parse the response data.
    var parser: DataParser { get }
    
    /// Intercept the final request object before it is used for the session.
    ///
    /// Default implementation provided. No changes will be made in the defualt handler.
    func intercept(urlRequest: URLRequest) throws -> URLRequest
    
    /// Validate the received `URLResponse`.
    ///
    /// Default implementation provided.
    func intercept(urlResponse: URLResponse) throws
    
    /// Handle the parameters that comform to `ParameterProtocol` found in `configuration`
    /// and add them to the request.
    ///
    /// Default implementation provided. The default implementation requires that all the parameters
    /// *must* have the same encoding with no duplicate keys, otherwise an error will be thrown.
    ///
    /// - parameter parameters: The parameters found in `configuration`.
    /// - parameter request: The request object to be processed.
    /// - returns: A request that contains the given parameters.
    /// - throws: Any error occured during the processing process
    func handleParameters(_ parameters: [ParameterProtocol], for request: URLRequest) throws -> URLRequest
    
    /// Handle the headers that comform to `HeaderProtocol` found in `configuration`
    /// and add them to the request.
    ///
    /// Default implementation provided. The default implementation requires that all the headers *must* have
    /// no duplicate keys, otherwise an error will be thrown.
    ///
    /// - parameter parameters: The parameters found in `configuration`.
    /// - parameter request: The request object to be processed.
    /// - returns: A request that contains the given parameters.
    /// - throws: Any error occured during the processing process
    func handleHeaders(_ headers: [HeaderProtocol], for request: URLRequest) throws -> URLRequest
}

public extension Request {
    /// Perform the request.
    ///
    /// - parameter completion: The completion handler for the response.
    /// - returns: The `URLSessionTask` object for the request.
    /// - throws: Error of processing url, headers and parameters.
    @discardableResult
    func perform(completion: @escaping (Result<Response, RequestError>) -> Void) throws -> URLSessionTask {
        let request = try urlRequest()
        try request.validate()
        
        let task = URLSession.shared.dataTask(with: request) { data, urlResponse, error in
            if let error = error {
                completion(.failure(.urlSessionError(error)))
                return
            }
            if let data = data, let urlResponse = urlResponse {
                do {
                    try intercept(urlResponse: urlResponse)
                    let response = try parser.parse(data: data)
                    completion(.success(response))
                } catch {
                    completion(.failure(.parsingError(error)))
                }
            } else {
                completion(.failure(.unknown))
            }
        }
        
        task.resume()
        
        return task
    }
    
    func intercept(urlRequest: URLRequest) throws -> URLRequest {
        return urlRequest
    }

    func intercept(urlResponse: URLResponse) throws {
        if let response = urlResponse as? HTTPURLResponse {
            guard 200..<300 ~= response.statusCode else {
                throw ResponseError.unacceptableStatusCode(response.statusCode)
            }
        }
    }
    
    func handleParameters(_ parameters: [ParameterProtocol], for request: URLRequest) throws -> URLRequest {
        if parameters.isEmpty { return request }
        var encoding: ParameterEncoding?
        var dictionary = [String : Encodable]()
        for parameter in parameters {
            if let encoding = encoding {
                if !isSameEncoding(encoding, parameter.encoding) {
                    throw RequestError.parameterError(.mismatchedEncoding)
                }
            } else {
                encoding = parameter.encoding
            }
            
            try dictionary.merge(parameter.parameters()) { _, _ in
                throw RequestError.parameterError(.duplicateKey)
            }
        }
        
        return try encoding!.encode(request, with: dictionary)
    }
    
    func handleHeaders(_ headers: [HeaderProtocol], for request: URLRequest) throws -> URLRequest {
        if headers.isEmpty { return request }
        var dictionary = [String : String]()
        for header in headers {
            try dictionary.merge(header.header()) { _, _ in
                throw RequestError.parameterError(.duplicateKey)
            }
        }
        var request = request
        request.headers = .init(dictionary)
        return request
    }
}

extension Request {
    func isSameEncoding(_ lhs: ParameterEncoding, _ rhs: ParameterEncoding) -> Bool {
        if let lhs = lhs as? URLEncoding, let rhs = rhs as? URLEncoding {
            return lhs == rhs
        }
        
        if let lhs = lhs as? JSONEncoding, let rhs = rhs as? JSONEncoding {
            return lhs == rhs
        }
        
        return false
    }
    
    func urlRequest() throws -> URLRequest {
        let url = path.isEmpty ? base : base.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.method = method

        request.setValue(parser.contentType, forHTTPHeaderField: "Accept")
        
        request = try inspectParameters(for: request)
        request = try inspectHeaders(for: request)
        
        return try intercept(urlRequest: request)
    }
}
