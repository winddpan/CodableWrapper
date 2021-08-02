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
        self.init(defaultValue: Wrapped?.none, construct: Construct(codingKeys: key, transformer: nil))
    }

    ///
    /// ```
    /// @Coding var uid: String = ""
    /// @Coding("userId") var uid: String? = nil
    ///
    convenience init(wrappedValue: Value, _ key: String ...) {
        self.init(defaultValue: wrappedValue, construct: Construct(codingKeys: key, transformer: nil))
    }
}

public extension Codec {
    ///
    /// ```
    /// @Codec("enum", "enumValue", transformer: TransformOf<EnumInt, Int>(fromNull: { .none }, fromJSON: { EnumInt(rawValue: $0) }, toJSON: { $0.rawValue }))
    /// var enumValue: EnumInt?
    ///
    convenience init<Wrapped, T: TransformType>(_ key: String ..., transformer: T) where Value == Wrapped?, T.Value == Wrapped {
        self.init(defaultValue: Wrapped?.none, construct: Construct(codingKeys: key, transformer: TransfromTypeTunk(transformer)))
    }

    ///
    /// ```
    /// @Codec("enum", "enumValue", transformer: TransformOf<EnumInt?, Int>(fromNull: { .none }, fromJSON: { EnumInt(rawValue: $0) }, toJSON: { $0.rawValue }))
    /// var enumValue: EnumInt?
    ///
    convenience init<Wrapped, T: TransformType>(_ key: String ..., transformer: T) where Value == Wrapped?, T.Value == Wrapped? {
        self.init(defaultValue: Wrapped?.none, construct: Construct(codingKeys: key, transformer: TransfromTypeTunk(transformer)))
    }

    ///
    /// ```
    /// @Codec("enum", "enumValue", transformer: TransformOf<EnumInt, Int>(fromNull: { .none }, fromJSON: { EnumInt(rawValue: $0) }, toJSON: { $0.rawValue }))
    /// var enumValue: EnumInt = .none
    ///
    convenience init<T: TransformType>(wrappedValue: Value, _ key: String ..., transformer: T) where T.Value == Value {
        self.init(defaultValue: wrappedValue, construct: Construct(codingKeys: key, transformer: TransfromTypeTunk(transformer)))
    }
}
