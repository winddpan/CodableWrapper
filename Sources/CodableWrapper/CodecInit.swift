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
    /// @Coding("userId") var uid: String?
    ///
    convenience init<Wrapped>(_ key: String ...) where Value == Wrapped? {
        self.init(defaultValue: Wrapped?.none, construct: CodecConstruct(codingKeys: key))
    }

    ///
    /// ```
    /// @Coding("userId") var uid: String = "0"
    ///
    convenience init(wrappedValue: Value, _ key: String ...) {
        self.init(defaultValue: wrappedValue, construct: CodecConstruct(codingKeys: key))
    }
}

public extension Codec {
    ///
    /// ```
    /// struct ValueWrapper {
    ///     var value: String?
    /// }
    /// ```
    /// @Codec(transformer: TransformOf<ValueWrapper, String>(fromJSON: { ValueWrapper(value: $0) }, toJSON: { $0.value }))
    /// var nonCodable = ValueWrapper(value: nil)
    ///
    convenience init<Wrapped, T: TransformType>(_ keys: [String] = [], transformer: T) where Value == Wrapped? {
        self.init(defaultValue: Wrapped?.none, construct: CodecConstruct(codingKeys: keys, transformer: AnyTransfromTypeTunk(transformer)))
    }

    ///
    /// ```
    /// struct ValueWrapper {
    ///     var value: String?
    /// }
    /// ```
    /// @Codec(transformer: TransformOf<ValueWrapper?, String>(fromJSON: { $0 != nil ? ValueWrapper(value: $0) : nil }, toJSON: { $0?.value }))
    /// var nonCodableOptional: ValueWrapper?
    ///
    convenience init<T: TransformType>(wrappedValue: Value, _ keys: [String] = [], transformer: T) {
        self.init(defaultValue: wrappedValue, construct: CodecConstruct(codingKeys: keys, transformer: AnyTransfromTypeTunk(transformer)))
    }
}
