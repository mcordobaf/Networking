//
//  File.swift
//  
//
//  Created by Marco Córdoba Fernández on 08-08-21.
//

import Foundation

public protocol TokenStorageProtocol{
  associatedtype Token
  var userDefaults:UserDefaults { get }
  var key:TokenKey { get }
  var wrappedValue:Token? { get }
}

@propertyWrapper
public class TokenStorage<Token>:TokenStorageProtocol{
  public var userDefaults:UserDefaults = UserDefaults.standard
  public var key:TokenKey = .tokenKey
  public var wrappedValue:Token? {
    get {
      userDefaults.object(forKey: self.key.rawValue) as? Token
    }
    set{
      userDefaults.setValue(newValue, forKey: self.key.rawValue)
      userDefaults.synchronize()
    }
  }
  
  public init(wrappedValue:Token? = nil) {
    self.wrappedValue = wrappedValue
  }
}

public enum TokenKey:String {
  case tokenKey
}
