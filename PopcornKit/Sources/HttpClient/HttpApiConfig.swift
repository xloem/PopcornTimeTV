//
//  HttpApiConfig.swift
//  
//
//  Created by Alexandru Tudose on 15.12.2021.
//

import Foundation

enum HTTPMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}

typealias HTTPHeaders = [String: String]

struct HttpApiConfig {
    var serverURL: String
    
    var configuration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        configuration.httpCookieAcceptPolicy = .never
        configuration.httpShouldSetCookies = false
        configuration.timeoutIntervalForResource = 30
//        configuration.urlCache = nil
//        configuration.requestCachePolicy = .returnCacheDataDontLoad
        configuration.httpAdditionalHeaders = ["User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_16_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.138 Safari/"]
        return configuration
    }()
}

