//
//  File.swift
//  
//
//  Created by Alexandru Tudose on 15.12.2021.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
}

typealias HTTPHeaders = [String: String]

struct HttpApiConfig {
    var serverURL: String
    var defaultTimeout = 30.0 // seconds
    var cachePolicy = URLRequest.CachePolicy.useProtocolCachePolicy
    
    var httpHeaders: HTTPHeaders = ["Content-Type": "application/json"]
}

