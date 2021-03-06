import Foundation

/// `Parser` protocol provides interface to parse HTTP response body and to state Content-Type to accept.
public protocol Parser {
    associatedtype Object
    /// Value for `Accept` header field of HTTP request.
    var contentType: String? { get }

    /// Return `Any` that expresses structure of response such as JSON and XML.
    /// - Throws: `Error` when parser encountered invalid format data.
    func parse(data: Data) throws -> Object
}
