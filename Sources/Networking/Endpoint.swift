//
//  File.swift
//  
//
//  Created by Marco Córdoba Fernández on 08-08-21.
//

import Foundation

public typealias Headers = [String:String]
public typealias Parameters = [String:String]

public protocol EndpointProtocol{
  associatedtype Body = Codable
  var url:URL? { get }
  var requestMethod:RequestMethod { get }
  var headers:Headers? { get }
  var authentication:AuthenticationType? { get }
  var parameters:Parameters? { get }
  var body:Body? { get }
  func getBody() -> Data?
}

public final class Endpoint<Body:Codable>:EndpointProtocol{
  public var url:URL?
  public var requestMethod: RequestMethod
  public var headers: Headers?
  public var authentication: AuthenticationType?
  public var parameters:Parameters?
  public var body: Body?
  
  public init(
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
  
  public func getBody() -> Data? {
    if let body = self.body, let bodyEncoded = try? JSONEncoder().encode(body){
      return bodyEncoded
    }
    return nil
  }
}

public class EndpointDI{
  public static func diBuilder<Body:Codable>(
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
  
  public static func diBuilder<AnyCodable:Codable>(
    urlComponents:URLComponents,
    requestMethod:RequestMethod,
    headers:Headers,
    authentication:AuthenticationType?,
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
