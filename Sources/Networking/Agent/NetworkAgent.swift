//
//  File.swift
//  
//
//  Created by Marco Córdoba Fernández on 08-08-21.
//

import Foundation

public protocol NetworkAgentProtocol{
  var networkProvider:NetworkProviderProtocol { get }
}

public final class NetworkAgent:NetworkAgentProtocol {
  public var networkProvider: NetworkProviderProtocol
  init(networkProvider:NetworkProviderProtocol = NetworkProvider()) {
    self.networkProvider = networkProvider
  }
}
