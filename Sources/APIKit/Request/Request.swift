//
//  Request.swift
//  APIKit
//
//  Created by 梁业升 on 2021/8/27.
//  Copyright © 2021 梁业升. All rights reserved.
//

import Foundation

public protocol Request {
    associatedtype Configuration: RequestConfiguration
    associatedtype Response
    associatedtype DataParser: Parser
    
    var base: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    
    var configuration: Configuration { get }
    var parser: DataParser { get }

    func response(from object: DataParser.Object, urlResponse: URLResponse) throws -> Response
    
    func intercept(urlRequest: URLRequest) throws -> URLRequest
    func intercept(urlResponse: URLResponse) throws
    func handleParameters(_ parameters: [ParameterProtocol], for request: URLRequest) throws -> URLRequest
    func handleHeaders(_ headers: [HeaderProtocol], for request: URLRequest) throws -> URLRequest
}

public extension Request {
    @discardableResult
    func perform(completion: @escaping (Result<Response, RequestError>) -> Void) -> URLSessionTask? {
        do {
            let request = try urlRequest()
            
            let task = URLSession.shared.dataTask(with: request) { data, urlResponse, error in
                if let error = error {
                    completion(.failure(.urlSessionError(error)))
                    return
                }
                if let data = data, let urlResponse = urlResponse {
                    do {
                        try intercept(urlResponse: urlResponse)
                        let object = try parser.parse(data: data)
                        let reponse = try response(from: object, urlResponse: urlResponse)
                        completion(.success(reponse))
                    } catch {
                        completion(.failure(.parsingError(error)))
                    }
                } else {
                    completion(.failure(.unknown))
                }
            }
            
            task.resume()
            
            return task
            
        } catch {
            completion(.failure(.parameterError(.unknown(error))))
        }
        
        return nil
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
