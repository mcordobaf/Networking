//
//  File.swift
//  
//
//  Created by Marco Córdoba Fernández on 08-08-21.
//

import Foundation
import Combine

public typealias DataTaskResult = (data: Data, response: URLResponse)

public struct ApiErrorResponse: LocalizedError, Decodable {
  let message: String
  public var errorDescription: String? { message }
}

public enum ValidationError: Error {
  case error(Error)
  case notFound(Data)
  case jsonError(Data)
  case errorStatusCode(Error, Int)
}

extension ValidationError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .notFound(let d): return "Not found: \(String.init(data: d, encoding: .utf8) ?? "\(d)")"
    case .error(let e): return "\(e)"
    case .jsonError(let d): return "Custom Json Error: \(String.init(data: d, encoding: .utf8) ?? "\(d)")"
    case .errorStatusCode(let errorString, let statusCode): return "Error: \(errorString) status code \(statusCode)"
    }
  }
}

public extension Publisher where Output == DataTaskResult {

  func validateStatusCode(_ isValid: @escaping (Int) -> Bool) -> AnyPublisher<Output, ValidationError> {
    return validateResponse { (data, response) in
      let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
      return isValid(statusCode)
    }
  }

  func validateResponse(_ isValid: @escaping (DataTaskResult) -> Bool) -> AnyPublisher<Output, ValidationError> {
    return self
      .mapError {
        .error($0)
      }
      .flatMap{ (result) -> AnyPublisher<DataTaskResult, ValidationError> in
        let (data, urlResponse) = result
        if isValid(result) {
          return Just(result)
            .setFailureType(to: ValidationError.self)
            .eraseToAnyPublisher()
        } else {
          if let httpResponse = urlResponse as? HTTPURLResponse
          {
            return Fail(outputType: Output.self, failure: .errorStatusCode(NSError(domain: httpResponse.description, code: httpResponse.statusCode, userInfo: nil), httpResponse.statusCode))
              .eraseToAnyPublisher()
          }else{
            return Fail(outputType: Output.self, failure: .jsonError(data))
              .eraseToAnyPublisher()
          }
        }
      }
      .eraseToAnyPublisher()
  }
}

public extension Publisher where Failure == ValidationError {
  func mapJsonError<E: Error & Decodable>(to errorType: E.Type, decoder: JSONDecoder) -> AnyPublisher<Output, Error> {
    return self
      .tryCatch({ (error: ValidationError) -> AnyPublisher<Output, Error> in
        switch error {
        case .error(let e):
          return Fail(outputType: Output.self, failure: e)
            .eraseToAnyPublisher()
        case .jsonError(let d), .notFound(let d):
          return Just(d)
            .decode(type: E.self, decoder: decoder)
            .flatMap { Fail(outputType: Output.self, failure: $0) }
            .eraseToAnyPublisher()
        case .errorStatusCode(_,_):
          return Fail(outputType: Output.self, failure: error)
            .eraseToAnyPublisher()
        }
      })
      .eraseToAnyPublisher()
  }
}

public extension Publisher where Output == DataTaskResult {
  func mapJsonValue<Output: Decodable>(to outputType: Output.Type, decoder: JSONDecoder) -> AnyPublisher<Output, Error> {
    return self
      .map(\.data)
      .decode(type: outputType, decoder: decoder)
      .eraseToAnyPublisher()
  }
}

public func serializeDictionaryToData(dictionary:[String : Any]) -> Data?{
  var data:Data?
  do{
    data = try JSONSerialization.data(withJSONObject: dictionary, options: JSONSerialization.WritingOptions.prettyPrinted)
  }
  catch {
    print("Error to serialize json to data")
  }
  return data
}

public func decode<T: Decodable>(_ data: Data) -> AnyPublisher<T, GenericError> {
  let decoder = JSONDecoder()
  decoder.dateDecodingStrategy = .secondsSince1970

  return Just(data)
    .decode(type: T.self, decoder: decoder)
    .mapError { error in
      .parsing(description: error)
    }
    .eraseToAnyPublisher()
}
