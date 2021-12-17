//
//  File.swift
//  
//
//  Created by Alexandru Tudose on 15.12.2021.
//

import Foundation
import ObjectMapper


struct HttpSessionRequest {
    var request: URLRequest
    var session: URLSession = .shared
    var validStatuses = (200...299)
    var missingSession = [401]
    var closeSession: (_ error: Error) -> Void = { error in  }
    
    func response() async throws {
        let (data, response): (Data, URLResponse) = try await session.data(for: request)
        try validate(request: request, response: response, data: data)
    }
    
    func responseDecode<T: Decodable>(keyPath: String? = nil, decoder: JSONDecoder = .default) async throws -> T {
        let (data, response): (Data, URLResponse) = try await session.data(for: request)
        try validate(request: request, response: response, data: data)
        
        do {
            var object: T
            if let keyPath = keyPath {
                object = try decoder.decode(T.self, from: data, keyPath: keyPath, separator: ".")
            } else {
                object = try decoder.decode(T.self, from: data)
            }
            return object
        } catch (let error as DecodingError) {
            print(error.debugDescription)
            throw error
        } catch {
            print("unknown error", error.localizedDescription)
            throw error
        }
    }
    
    func responseMapable<T: Mappable>(keyPath: String? = nil, decoder: JSONDecoder = .default) async throws -> [T] {
        let (data, response): (Data, URLResponse) = try await session.data(for: request)
        try validate(request: request, response: response, data: data)
        
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw APIError.Type_.missingContent
        }
        guard let response = Mapper<T>().mapArray(JSONString: jsonString) else {
            throw APIError.Type_.couldNoteDecodeResponse
        }
        
        return response
    }
    
    func responseMapable<T: Mappable>(keyPath: String? = nil, decoder: JSONDecoder = .default) async throws -> T {
        let (data, response): (Data, URLResponse) = try await session.data(for: request)
        try validate(request: request, response: response, data: data)
        
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw APIError.Type_.missingContent
        }
        guard let response = Mapper<T>().map(JSONString: jsonString) else {
            throw APIError.Type_.couldNoteDecodeResponse
        }
        
        return response
    }
    
    func validate(request: URLRequest, response: URLResponse, data: Data?) throws {
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
            throw APIError.Type_.invalidHttpStatusCode
        }
        
        guard validStatuses.contains(statusCode) else {
            
            print("\n Request failed: ",
                  request.httpMethod ?? "",
                  request.url?.absoluteString ?? "",
                  "\n\tResponse: " + (data.flatMap({ String(data:$0, encoding: .utf8) }) ?? ""))
            
            let accessDenied = missingSession.contains(statusCode)
            
            if accessDenied {
                DispatchQueue.main.async {
                    closeSession(APIError.Type_.missingSession)
                }
            }
            
            throw APIError.Type_.invalidHttpStatusCode
        }
    }
}

