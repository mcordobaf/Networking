//
//  File.swift
//  
//
//  Created by Marco Córdoba Fernández on 08-08-21.
//

import Foundation
import Combine

public protocol NetworkProviderProtocol:AnyObject{
  var session:URLSession { get }
  var authenticatorManager:AuthenticationManager { get }
  func run<T:Codable, EndpointProtocolImplemented:EndpointProtocol>(endpoint:EndpointProtocolImplemented) -> AnyPublisher<T, GenericError>
}

public final class NetworkProvider:NetworkProviderProtocol{
  public var authenticatorManager:AuthenticationManager
  public var session: URLSession
  init(authenticatorManager:AuthenticationManager = AuthenticationManager()) {
    let configuration = URLSessionConfiguration.default
    configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
    self.session = URLSession(configuration: configuration)
    self.authenticatorManager = authenticatorManager
  }
  
  public func run<T:Codable, EndpointProtocolImplemented>(endpoint: EndpointProtocolImplemented) -> AnyPublisher<T, GenericError> where EndpointProtocolImplemented : EndpointProtocol {
    guard let url = endpoint.url else {
      return Fail(error: GenericError.network(description: "error")).eraseToAnyPublisher()
    }
    
    var urlRequest = URLRequest(url: url)
    urlRequest.setValue(Constants.CONTENT_TYPE_JSON_VALUE.toString(), forHTTPHeaderField: Constants.CONTENT_TYPE_JSON_KEY.toString())
    if let headers = endpoint.headers{
      for (key, value) in headers{
        urlRequest.setValue(value, forHTTPHeaderField: key)
      }
    }
    
    if let _ = endpoint.authentication, let authentication = authenticatorManager.getAuthentication()?.first{
      urlRequest.setValue(authentication.value, forHTTPHeaderField: authentication.key)
    }
    urlRequest.httpMethod = endpoint.requestMethod.rawValue
    if let body = endpoint.getBody(){
      urlRequest.httpBody = body
    }
    
    debugPrint(urlRequest)
    let id = UUID()
    debugPrint("--> START REQUEST with id request: \(id)")

    return session.dataTaskPublisher(for: urlRequest)
      .validateStatusCode({(200..<300).contains($0)})
      .validateResponse {
        #if DEBUG
        let dataResponse = String(decoding: $0.data, as: UTF8.self)
        debugPrint("--> id request: \(id)")
        debugPrint("--> START DATA RESPONSE")
        debugPrint(dataResponse)
        debugPrint("--> END DATA RESPONSE")
        #endif
        return !$0.data.isEmpty
      }
      .mapJsonError(to: ApiErrorResponse.self, decoder: JSONDecoder())
      .mapError { error in
        return self.processErrorToGeneric(errorValidation: error as? ValidationError)
      }
      .flatMap(maxPublishers: .max(1)) { pair in
        decode(pair.data)
      }
      .eraseToAnyPublisher()
  }
  
  private func processErrorToGeneric(errorValidation:ValidationError?) -> GenericError{
    switch errorValidation {
    case .errorStatusCode(let error, let statusCode):
      return GenericError.statusCodeError(statusCodeError: statusCode, error: error)
    default:
      return .network(description: errorValidation?.localizedDescription ?? "")
    }
  }
}
