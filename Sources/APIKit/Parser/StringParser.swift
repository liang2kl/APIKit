import Foundation

/// `StringParser` parses data and convert it to string.
public struct StringParser: Parser {
    public typealias Object = String
    public enum Error: Swift.Error {
        case invalidData(Data)
    }

    /// The string encoding of the data.
    public let encoding: String.Encoding

    /// Returns `StringParser` with the string encoding.
    public init(encoding: String.Encoding = .utf8) {
        self.encoding = encoding
    }

    // MARK: - DataParser

    /// Value for `Accept` header field of HTTP request.
    public var contentType: String? {
        return nil
    }

    /// Return `String` that converted from `Data`.
    /// - Throws: `StringParser.Error` when the parser fails to initialize `String` from `Data`.
    public func parse(data: Data) throws -> Object {
        guard let string = String(data: data, encoding: encoding) else {
            throw Error.invalidData(data)
        }

        return string
    }
}
