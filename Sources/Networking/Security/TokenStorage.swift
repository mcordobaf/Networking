//
//  File.swift
//  
//
//  Created by Marco Córdoba Fernández on 08-08-21.
//

import Foundation

protocol TokenStorageProtocol{
  associatedtype Token
  var userDefaults:UserDefaults { get }
  var key:TokenKey { get }
  var wrappedValue:Token? { get }
}

@propertyWrapper
class TokenStorage<Token>:TokenStorageProtocol{
  internal var userDefaults:UserDefaults = UserDefaults.standard
  internal var key:TokenKey = .tokenKey
  var wrappedValue:Token? {
    get {
      userDefaults.object(forKey: self.key.rawValue) as? Token
    }
    set{
      userDefaults.setValue(newValue, forKey: self.key.rawValue)
      userDefaults.synchronize()
    }
  }
  
  init(wrappedValue:Token? = nil) {
    self.wrappedValue = wrappedValue
  }
}

enum TokenKey:String {
  case tokenKey
}
