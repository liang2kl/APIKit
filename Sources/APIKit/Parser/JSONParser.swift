import Foundation

/// `JSONParser` response JSON data.
public struct JSONParser<Object: Decodable>: Parser {
    let decoder: JSONDecoder

    public init(decoder: JSONDecoder = .init()) {
        self.decoder = decoder
    }

    // MARK: - DataParser

    /// Value for `Accept` header field of HTTP request.
    public var contentType: String? {
        return "application/json"
    }

    /// Return `Any` that expresses structure of JSON response.
    /// - Throws: `NSError` when `JSONSerialization` fails to deserialize `Data` into `Any`.
    public func parse(data: Data) throws -> Object {
        return try decoder.decode(Object.self, from: data)
    }
}
