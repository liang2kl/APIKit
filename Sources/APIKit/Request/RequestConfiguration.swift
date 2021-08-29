//
//  RequestConfiguration.swift
//  APIKit
//
//  Created by 梁业升 on 2021/8/27.
//  Copyright © 2021 梁业升. All rights reserved.
//

import Foundation

/// Protocol for configuration objects that contain request headers and parameters.
///
/// To define a configuration type, firstly conform it to `RequestConfiguration`:
///
/// ```swift
/// struct MyConfiguration: RequestConfiguration {
/// }
/// ```
///
/// Then add members to the configuration type. Only properties that conform to
/// `HeaderProtocol` and `ParameterProtocol` will be discovered by
/// the request, but you can add any other members if you need.
///
/// ```swift
/// struct MyConfiguration: RequestConfiguration {
///     @Header("TOKEN") var token = nil
///     @Query("page") var page: Int = nil
/// }
/// ```
///
/// The properties that conforms to `HeaderProtocol` will present in
/// `handleHeaders` of the request, and `ParameterProtocol` will
/// present in `handleParameters` call.
public protocol RequestConfiguration {}
