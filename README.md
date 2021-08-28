# APIKit

Simplify HTTP request declaration and processing with pre-defined property wrappers.

```swift
struct SetPushRequest: JSONDecodableRequest, RequestConfiguration {
    @Header("TOKEN") var accessToken = nil
    @Field("push_system_msg") var pushSystemMessage: Bool? = nil
    @Field("push_reply_me") var pushReplyMe: Bool? = nil
    @Field("push_favorited") var pushFavourite: Bool? = nil
    
    struct Response: Codable {
        var code: Int
        var msg: String?
    }

    let base: URL = URL(string: "https://dev-api.thuhole.com")!
    let path: String = "v3/config/set_push"
    let method: HTTPMethod = .post
    
    var configuration: Self { return self }
}

let request = SetPushRequest(accessToken: token, pushSystemMessage: true, pushReplyMe: true, pushFavourite: false)
request.perform { result in
    switch result {
    case .success(let response):
        print(response)

    case .failure(let error):
        print(error)
    }
}
```

## Usage

### Define Your Requests Conforming to `Request`

Protocol `Request` is an abstraction of an HTTP request:

```swift
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
}
```

To define a request, you need to provide:

- API information:
    - `var base: URL` Base URL of the API
    - `var path: String` URL path
    - `var method: HTTPMethod` HTTP method
- Configuration: request parameters, which will be discussed later:
    - `associatedtype Configuration`
    - `var configuration: Configuration`
- Response type and parser to parse data from the request, which will be discussed later:
    - `associatedtype DataParser: Parser` DataParser type that conforming to `Parser`
    - `var parser: DataParser { get }` The parser to parse the received data
    - `associatedtype Response` The final data that the request returns
    - `func response()` Convert parser's data to `Response`

Additionally and optionally, you can customize the intermediate process.

```swift
func intercept(urlRequest: URLRequest) throws -> URLRequest
func intercept(urlResponse: URLResponse) throws
```

If `Response` type can be parsed from JSON data, you can instead conforming to `JSONDecodableRequest`, which has default implementation of `var parser` and `func response()`.

### Provide Request Parameters

APIKit provides simple ways to pass request parameters.

First, define your Configuration type that conforming to `RequestConfiguration`:

```swift
struct MyConfiguration: RequestConfiguration {
    
}
```

`RequestConfiguration` is nothing than a type constraint. It has no implementation requirements, and is only used to distinguish from other types.

Then, you can add your parameters into `MyConfiguration` as its member. You can add these types of parameters:

| Property Wrapper | Description | Wrapped Value |
| --- | --- | --- |
| `@Header` | HTTP Header | `String?` |
| `@HeaderDict` | An dictionary of headers | `[String : String]` |
| `@Query` | Query parameters | `Encodable` |
| `@QueryDict` | An dictionary of query parameters | `[String : String]?` |
| `@KeyQuery` | Query parameters with no value associated | `Bool` |
| `@JSON` | Body parameters with JSON encoding | `Encodable?` |
| `@Field` | Form URL Encoded parameters | `Encodable?` |

Noted that some wrapped values are `Optional`. When the wrapped value is `nil`, the parameter will not be encoded.

Multipart requests is currently unsupported.

#### Header

To add a header into the request, define a property inside your configuration, providing header field string:

```swift
@Header("TOKEN") var token = nil
```

The type of the wrapped value `token` is `String?`. As for the property wrapper constraint, you must provide an initial value (and that applys to all following parameter types). When the value is `nil`, the header field will not be added.

#### Query Parameters

To add a query parameter with `Encodable` value and the query key:

```swift
@Query("key") var value: Int? = nil
```

When the value is `nil`, this parameter will not present.

To add a query without value:

```swift
@KeyQuery("key") var value: Bool = false
```

If the value is `true`, then `key` will be encoded into the URL (something like `...?key&other_key=...`). If it's `false`, the key will not present.

To add a dictionary of query parameters (`[String : String]`):

```swift
@QueryDict var parameters = [
    "first_key" : "first_value",
    "second_key" : "second_value",
    ...
]
```

This is useful for providing a set of constant parameters.

#### Body Parameters

The declaration is similar to `@Query`.

To add JSON encoded data into HTTP body:

```swift
@JSON("key") value: Int? = nil
```

> Multiple `@JSON` parameters in a single `RequestConfiguration` type
> will be encoded into **a single JSON object**.
> 
> For Example:
> 
> ```swift
> struct MyConfiguration: RequestConfiguration {
>     @JSON("key_1") var value1 = 1
>     @JSON("key_2") var value2 = "value_2"
> }
> ```
>
> They will be encoded into:
>
> ```json
> {
>   "key_1": 1,
>   "key_2": "value_2"
> }
> ```

To add Form URL Encoded parameters into HTTP body:

```swift
@Field("key") value: Int? = nil
```

### Provide a Parser

A parser is an object that `Request` uses to transform recieved data into a desired objet:

```swift
public protocol Parser {
    associatedtype Object
    var contentType: String? { get }
    func parse(data: Data) throws -> Object
}
```

`Object` is the type of the output object, `contentType` is the header value for field `Accept`,
and `parse()` is the transformer of the received data.

Typically you don't need to create a `Parser` of your own. You can use the pre-defined `JSONParser`,
`FormURLEncodedDataParser` and `StringParser` to parse the data.

### Perform the Request

After defining your request like this:

```swift
struct SetPushRequest: JSONDecodableRequest, RequestConfiguration {
    @Header("TOKEN") var accessToken = nil
    @Field("push_system_msg") var pushSystemMessage: Bool? = nil
    @Field("push_reply_me") var pushReplyMe: Bool? = nil
    @Field("push_favorited") var pushFavourite: Bool? = nil
    
    struct Response: Codable {
        var code: Int
        var msg: String?
    }

    let base: URL = URL(string: "https://dev-api.thuhole.com")!
    let path: String = "v3/config/set_push"
    let method: HTTPMethod = .post
    
    var configuration: Self { return self }
}
```

All you have to do is calling `perform()` of the request:

```swift
let request = SetPushRequest(accessToken: token, pushSystemMessage: true, pushReplyMe: true, pushFavourite: false)
request.perform { result in
    switch result {
    case .success(let response):
        // response is `SetPushRequest.Response` type
        ...
    case .failure(let error):
        // error is `RequestError` type
        ...
    }
}
```

## How It Works

APIKit uses `Mirror` to inspect the properties of an `RequestConfiguration` instance and search for properties
that comforming to certain protocols.

For example, `@Header`, `@HeaderDict` confrom to `HeaderProtocol`, and `@JSON`, `@Field` conform to `BodyProtocol`.
When we discover properties that conform to these protocols, we can access the information (keys, values, etc.) they provide
and use it to construct the request.

So, it's 100% OK to define a custom property wrapper that conforms to one of `HeaderProtocol`, `QueryProtocol` and `BodyProtocol`,
and put properties that are wrapped by the wrapper into `RequestConfiguration` types, to customize their behaviours.
