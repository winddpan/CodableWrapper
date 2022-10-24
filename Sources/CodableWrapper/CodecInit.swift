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
    /// @Codec var uid: String?
    ///
    init<Wrapped>() where Value == Wrapped? {
        self.init(defaultValue: Wrapped?.none, construct: CodecConstruct<Value>(codingKeys: []))
    }

    ///
    /// ```
    /// @Codec("userId") var uid: String = "0"
    /// @Codec("userId") var uid: String? = nil
    ///
    init(wrappedValue: Value, _ key: String ..., noNested: Bool = false) {
        self.init(defaultValue: wrappedValue, construct: CodecConstruct<Value>(codingKeys: key.map { .init(key: $0, noNested: noNested) }))
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
    init<Wrapped, T: TransformType>(_ keys: [String] = [], noNested: Bool = false, transformer: T) where Value == Wrapped? {
        self.init(defaultValue: Wrapped?.none,
                  construct: CodecConstruct<Value>(codingKeys: keys.map { .init(key: $0, noNested: noNested) },
                                                   transformer: AnyTransfromTypeTunk(transformer)))
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
    init<T: TransformType>(wrappedValue: Value, _ keys: [String] = [], noNested: Bool = false, transformer: T) {
        self.init(defaultValue: wrappedValue,
                  construct: CodecConstruct<Value>(codingKeys: keys.map { .init(key: $0, noNested: noNested) },
                                                   transformer: AnyTransfromTypeTunk(transformer)))
    }
}
