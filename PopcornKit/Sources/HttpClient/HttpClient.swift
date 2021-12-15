//
//  File.swift
//  
//
//  Created by Alexandru Tudose on 15.12.2021.
//

import Foundation

public class HttpClient {
    var config: HttpApiConfig
    
    init(config: HttpApiConfig) {
        self.config = config
    }
    
    func request(_ method: HTTPMethod, path: String, parameters: [String: Any]? = nil, headers: [String:String]? = nil) -> HttpSessionRequest {
        
        var urlComponents = URLComponents(string: config.serverURL)!
        urlComponents.path += path
        
        if method == .get, let parameters = parameters {
            urlComponents.queryItems = parameters.map {URLQueryItem(name: $0, value: $1 as? String)}
        }
        
        var request = URLRequest(url: urlComponents.url!, cachePolicy: config.cachePolicy, timeoutInterval: config.defaultTimeout)
        request.httpMethod = method.rawValue
        
        config.httpHeaders.forEach { (key, value) in
            request.setValue(value, forHTTPHeaderField: key)
        }
        headers?.forEach {
            request.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        
        if method != .get, let parameters = parameters {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return HttpSessionRequest(request: request)
    }
}
