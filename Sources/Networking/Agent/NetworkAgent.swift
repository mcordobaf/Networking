//
//  File.swift
//  
//
//  Created by Marco Córdoba Fernández on 08-08-21.
//

import Foundation

protocol NetworkAgentProtocol{
  var networkProvider:NetworkProviderProtocol { get }
}

final class NetworkAgent:NetworkAgentProtocol{
  var networkProvider: NetworkProviderProtocol
  init(networkProvider:NetworkProviderProtocol = NetworkProvider()) {
    self.networkProvider = networkProvider
  }
}
