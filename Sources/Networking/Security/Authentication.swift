//
//  File.swift
//  
//
//  Created by Marco Córdoba Fernández on 08-08-21.
//

import Foundation

public protocol AuthenticationProtocol:AnyObject{
  var tokenStorage:String? { get }
  func saveToken(authenticationType:AuthenticationType)
  func getAuthentication() -> Dictionary<String, String>?
}

public final class AuthenticationManager:AuthenticationProtocol{
  @TokenStorage public var tokenStorage:String?
  public func saveToken(authenticationType: AuthenticationType) {
    switch authenticationType {
    case .basicAuthentication(let basicAuthenticationToken):
      tokenStorage = basicAuthenticationToken
    case .bearerToken(let bearerToken):
      tokenStorage = bearerToken
    }
  }
  
  public func getAuthentication() -> Dictionary<String, String>? {
    guard let tokenStorage = tokenStorage else { return nil }
    return [ String(Constants.AUTHENTICATION_KEY) : tokenStorage ]
  }
}
