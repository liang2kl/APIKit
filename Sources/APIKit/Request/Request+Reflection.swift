//
//  Request+Reflection.swift
//  APIKit
//
//  Created by 梁业升 on 2021/8/27.
//  Copyright © 2021 梁业升. All rights reserved.
//

import Foundation

extension Request {
    // TODO: Error
    func urlString() throws -> String {
        let url = path.isEmpty ? base : base.appendingPathComponent(path)
        if !method.prefersQueryParameters {
            return url.absoluteString
        }
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            throw ParameterError.invalidURL(url.absoluteString)
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
            guard let string = components.percentEncodedQuery else {
                throw ParameterError.invalidURL(request.url?.absoluteString ?? "")
            }
            let data = string.data(using: .utf8)!
            request.httpBody = data
        }
    }
}
