//
//  APIError.swift
//  Networking
//
//  Created by Sergiu Corbu on 26.11.2021.
//

import Foundation

extension Error {
    var isNewtorkConnectionError: Bool {
        let nsError = self as NSError
        return nsError.code == NSURLErrorNotConnectedToInternet
    }
}

struct APIError: Error {
    
    enum Type_ {
        case missingSession
        case unkown
        case invalidHttpStatusCode
        case unacceptableStatusCode(code: Int)
        case missingContent
        case couldNotDecodeResponse
    }
    var message: String
    var type: Type_
    
    init(type: Type_) {
        self.type = type
        self.message = type.localizedDescription
    }
}


extension APIError.Type_ {
    var localizedDescription: String {
        switch self {
        case .missingSession: return "Missing Session"
        case .unkown: return "Unkwon"
        case .invalidHttpStatusCode: return "Invalid response status code."
        case .unacceptableStatusCode(let code): return "Response status code was unacceptable: \(code)."
        case .missingContent: return "Response could not be validated, data was nil."
        case .couldNotDecodeResponse: return "Response could not be decoded."
        }
    }
}

extension APIError: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case message
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decode(String.self, forKey: .message)
        type = .unkown
    }
}

extension APIError: LocalizedError {
    public var errorDescription: String? {
        return message
    }
}

//func ==(lhs: Error, rhs: APIError.Type_) -> Bool {
//    switch lhs {
//    case let error as APIError:
//        return error.type == rhs
//    default:
//        return false
//    }
//}

func ==(lhs: Error?, rhs: APIError.Type_) -> Bool {
    if let error = lhs {
        return error == rhs
    } else {
        return false
    }
}

func ==(lhs: APIError, rhs: Error) -> Bool {
    return rhs == lhs.type
}

func ==(lhs: Error, rhs: APIError) -> Bool {
    return lhs == rhs.type
}

