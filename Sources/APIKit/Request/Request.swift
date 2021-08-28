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
    
    func intercept(urlRequest: URLRequest) throws -> URLRequest
    func intercept(object: DataParser.Object, urlResponse: URLResponse) throws -> DataParser.Object

    func response(from object: DataParser.Object, urlResponse: URLResponse) throws -> Response
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
            completion(.failure(.parameterError(error)))
        }
        
        return nil
    }
    
    func intercept(urlRequest: URLRequest) throws -> URLRequest {
        return urlRequest
    }

    func intercept(object: DataParser.Object, urlResponse: URLResponse) throws -> DataParser.Object {
        if let response = urlResponse as? HTTPURLResponse {
            guard 200..<300 ~= response.statusCode else {
                throw ResponseError.unacceptableStatusCode(response.statusCode)
            }
        }
        return object
    }
}

extension Request {
    func urlRequest() throws -> URLRequest {
        let urlString = try urlString()
        guard let url = URL(string: urlString) else {
            throw ParameterError.invalidURL(urlString)
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        headers().forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        try addBody(to: &request)
        request.setValue(parser.contentType, forHTTPHeaderField: "Accept")
        return try intercept(urlRequest: request)
    }
}
