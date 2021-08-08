//
//  File.swift
//  
//
//  Created by Marco Córdoba Fernández on 08-08-21.
//

import Foundation

public enum GenericError: Error {
  case parsing(description: Error)
  case network(description: String)
  case notFound(error:Error)
  case statusCodeError(statusCodeError:Int, error:Error)
}
