//
//  File.swift
//  
//
//  Created by Marco Córdoba Fernández on 08-08-21.
//

import Foundation

public typealias Headers = [String:String]
public typealias Parameters = [String:String]

protocol EndpointProtocol{
  associatedtype Body = Codable
  var url:URL? { get }
  var requestMethod:RequestMethod { get }
  var headers:Headers? { get }
  var authentication:AuthenticationType? { get }
  var parameters:Parameters? { get }
  var body:Body? { get }
  func getBody() -> Data?
}

final class Endpoint<Body:Codable>:EndpointProtocol{
  var url:URL?
  var requestMethod: RequestMethod
  var headers: Headers?
  var authentication: AuthenticationType?
  var parameters:Parameters?
  var body: Body?
  
  init(
    urlComponents:URLComponents,
    requestMethod:RequestMethod,
    headers:Headers?,
    authentication:AuthenticationType?,
    parameters:Parameters?,
    body:Body? = nil) {
    self.url = urlComponents.url
    self.requestMethod = requestMethod
    self.headers = headers
    self.authentication = authentication
    self.parameters = parameters
    self.body = body
  }
  
  func getBody() -> Data? {
    if let body = self.body, let bodyEncoded = try? JSONEncoder().encode(body){
      return bodyEncoded
    }
    return nil
  }
}

class EndpointDI{
  static func diBuilder<Body:Codable>(
    urlComponents:URLComponents,
    requestMethod:RequestMethod,
    headers:Headers?,
    authentication:AuthenticationType?,
    parameters:Parameters?,
    body:Body) -> some EndpointProtocol {
    
    return Endpoint<Body>(
      urlComponents: urlComponents,
      requestMethod: requestMethod,
      headers: headers,
      authentication: authentication,
      parameters: parameters,
      body: body)
  }
  
  static func diBuilder<AnyCodable:Codable>(
    urlComponents:URLComponents,
    requestMethod:RequestMethod,
    headers:Headers,
    authentication:AuthenticationType,
    parameters:Parameters? = nil
  ) -> some EndpointProtocol{
    return Endpoint<AnyCodable>(
      urlComponents: urlComponents,
      requestMethod: requestMethod,
      headers: headers,
      authentication: authentication,
      parameters: parameters)
  }
}
