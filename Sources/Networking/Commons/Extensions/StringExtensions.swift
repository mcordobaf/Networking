//
//  File.swift
//  
//
//  Created by Marco Córdoba Fernández on 08-08-21.
//

import Foundation

extension String {
  init(_ staticString: StaticString) {
    self = staticString.withUTF8Buffer {
      String(decoding: $0, as: UTF8.self)
    }
  }
}
extension StaticString {
  func toString() -> String{
    return self.withUTF8Buffer {
      String(decoding: $0, as: UTF8.self)
    }
  }
}
