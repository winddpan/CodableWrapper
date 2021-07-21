//
//  CodecInit.swift
//  CodableWrapper
//
//  Created by xubin on 2021/7/21.
//

import Foundation

public extension Codec where Value: Codable {
    ///
    /// ```
    /// @Coding var uid: String?
    /// @Coding("userId") var uid: String?
    ///
    convenience init<Wrapped>(_ key: String ...) where Value == Wrapped? {
        self.init(codingKeys: key, defaultValue: Wrapped?.none)
    }
    
    ///
    /// ```
    /// @Coding var uid: String = ""
    /// @Coding("userId") var uid: String? = nil
    ///
    convenience init(wrappedValue: Value, _ key: String ...) {
        self.init(codingKeys: key, defaultValue: wrappedValue)
    }
}
