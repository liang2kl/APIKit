//
//  Request.swift
//  APIKit
//
//  Created by 梁业升 on 2021/8/27.
//  Copyright © 2021 梁业升. All rights reserved.
//

import Foundation

protocol RequestConfiguration {}

protocol Request {
    associatedtype Configuration: RequestConfiguration
    associatedtype Response
    
    var base: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    
    var configuration: Configuration { get set }
    
    func response(from data: Data) throws -> Response
}

protocol JSONDecodableRequest: Request where Response: Decodable {
    var decoder: JSONDecoder { get }
}

extension JSONDecodableRequest {
    func response(from data: Data) throws -> Response {
        return try decoder.decode(Response.self, from: data)
    }
}

extension Request {
    public func perform(completion: @escaping (Result<Response, Error>) -> Void) {
        do {
            let urlString = try urlString()
            guard let url = URL(string: urlString) else {
                // TODO: Error
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            headers().forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
            
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                if let data = data {
                    do {
                        let reponse = try response(from: data)
                        completion(.success(reponse))
                    } catch {
                        completion(.failure(error))
                    }
                } else {
                    // TODO: Error
                }
            }
            
            task.resume()
            
        } catch {
            completion(.failure(error))
        }
        
    }
}

extension Request {
    // TODO: Error
    internal func urlString() throws -> String {
        var url = URLComponents(string: base)!
        url.queryItems = url.queryItems ?? []
        let mirror = Mirror(reflecting: configuration)
        for (_, value) in mirror.children {
            if let value = value as? QueryProtocol {
                let items = try value.queryItems()
                items.forEach { url.queryItems!.append($0) }
            }
        }
        return url.string ?? ""
    }
    
    func headers() -> [String : String] {
        var headers = [String : String]()
        let mirror = Mirror(reflecting: configuration)
        for (_, value) in mirror.children {
            if let value = value as? Header {
                headers[value.field] = value.value
            }
        }
        return headers
    }
    
    // TODO: HTTP Body
}
