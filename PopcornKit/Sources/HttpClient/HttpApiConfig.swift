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
    
    var configuration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        configuration.httpCookieAcceptPolicy = .never
        configuration.httpShouldSetCookies = false
        configuration.timeoutIntervalForResource = 30
//        configuration.urlCache = nil
//        configuration.requestCachePolicy = .returnCacheDataDontLoad
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.httpAdditionalHeaders = ["User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_16_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.138 Safari/"]
        return configuration
    }()
}

