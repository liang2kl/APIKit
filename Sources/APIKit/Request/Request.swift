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
    func perform(completion: @escaping (Result<Response, Error>) -> Void) -> URLSessionTask? {
        do {
            let request = try urlRequest()
            
            let task = URLSession.shared.dataTask(with: request) { data, urlResponse, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                if let data = data, let urlResponse = urlResponse {
                    do {
                        let object = try parser.parse(data: data)
                        let reponse = try response(from: object, urlResponse: urlResponse)
                        completion(.success(reponse))
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    // TODO: Error
                }
            }
            
            task.resume()
            
            return task
            
        } catch {
            completion(.failure(error))
        }
        
        return nil
    }
    
    func intercept(urlRequest: URLRequest) throws -> URLRequest {
        return urlRequest
    }

    func intercept(object: DataParser.Object, urlResponse: HTTPURLResponse) throws -> DataParser.Object {
        guard 200..<300 ~= urlResponse.statusCode else {
            fatalError()
            // FIXME
//            throw ResponseError.unacceptableStatusCode(urlResponse.statusCode)
        }
        return object
    }
}

extension Request {
    // TODO: Error
    internal func urlString() throws -> String {
        let url = path.isEmpty ? base : base.appendingPathComponent(path)
        if !method.prefersQueryParameters {
            return url.absoluteString
        }
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            fatalError()
            // FIXME
        }
        components.queryItems = components.queryItems ?? []
        let mirror = Mirror(reflecting: configuration)
        for (_, value) in mirror.children {
            if let value = value as? QueryProtocol {
                let items = try value.queryItems()
                items.forEach { components.queryItems!.append($0) }
            }
        }
        return components.string ?? ""
    }
    
    func headers() -> [String : String] {
        var headers = [String : String]()
        let mirror = Mirror(reflecting: configuration)
        for (_, value) in mirror.children {
            if let value = value as? HeaderProtocol {
                headers.merge(value.header(), uniquingKeysWith: { _, new in new })
            }
        }
        return headers
    }
    
    func addBody(to request: inout URLRequest) throws {
        if method.prefersQueryParameters { return }
        var isJSON = false
        var isURL = false
        var jsonString = ""
        var components = URLComponents()
        components.queryItems = []
        let mirror = Mirror(reflecting: configuration)
        for (_, value) in mirror.children {
            if let value = value as? BodyProtocol,
               let entity = try value.entity() {
                
                request.setValue(value.contentType, forHTTPHeaderField: "Content-Type")

                switch entity {
                case .json(let string):
                    assert(!isURL, "Cannot combine JSON body with URL Encoded body")
                    isJSON = true
                    jsonString.append(string + ",")
                case .urlEncoded(let items):
                    assert(!isJSON, "Cannot combine JSON body with URL Encoded body")
                    isURL = true
                    components.queryItems!.append(contentsOf: items)
                }
            }
        }
        if isJSON {
            jsonString.removeLast()
            let string = "{\(jsonString)}"
            let data = string.data(using: .utf8)!
            request.httpBody = data
        } else {
            guard let string = components.string else { fatalError() /* FIXME */ }
            print(string)
            let data = string.data(using: .utf8)!
            request.httpBody = data
        }
    }
    
    func urlRequest() throws -> URLRequest {
        let urlString = try urlString()
        guard let url = URL(string: urlString) else {
            // TODO: Error
            fatalError()
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        headers().forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        try addBody(to: &request)
        request.setValue(parser.contentType, forHTTPHeaderField: "Accept")
        return try intercept(urlRequest: request)
    }
    
}
