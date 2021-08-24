//
//  File.swift
//  
//
//  Created by Marco Córdoba Fernández on 08-08-21.
//

import Foundation

public enum AuthenticationType {
  case basicAuthentication(String)
  case bearerToken(String)
}
