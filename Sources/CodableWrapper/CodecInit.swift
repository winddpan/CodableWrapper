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

public extension Codec {
//    convenience init<Wrapped, T: TransformType>(_ key: String ..., transformer: T) where Value == Wrapped?, T.Object == Wrapped {
//        self.init(codingKeys: key, defaultValue: Wrapped?.none, transformer: TransfromTypeTunk(transformer))
//    }
    
    convenience init<Wrapped, T: TransformType>(_ key: String ..., transformer: T) where Value == Wrapped?, T.Object == Wrapped? {
        self.init(codingKeys: key, defaultValue: Wrapped?.none, transformer: TransfromTypeTunk(transformer))
    }
    
    convenience init<T: TransformType>(wrappedValue: Value, _ key: String ..., transformer: T) where T.Object == Value {
        self.init(codingKeys: key, defaultValue: wrappedValue, transformer: TransfromTypeTunk(transformer))
    }
}
