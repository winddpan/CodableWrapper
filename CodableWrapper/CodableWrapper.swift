//
//  CodableWrapper.swift
//  CodableWrapper
//
//  Created by PAN on 2020/7/16.
//  Copyright © 2020 YR. All rights reserved.
//

import Foundation

@propertyWrapper
public class CodableWrapper<Value: Codable>: Codable {
    public struct Construct {
        public var defaultValue: Value
    }

    fileprivate var construct: Construct
    private var propertyKey: String?
    private var storedValue: Value?

    deinit {
        if let propertyKey = propertyKey {
            CodableWrapperCache.shared.clearCodableWrapperConstruct(type: Value.self, propertyKey: propertyKey)
        }
    }

    public convenience init(_ propertyKey: String, default defaultValue: Value) {
        self.init(propertyKey, construct: Construct(defaultValue: defaultValue))
    }

    public init(_ propertyKey: String, construct: Construct) {
        self.construct = construct
        self.propertyKey = propertyKey
        CodableWrapperCache.shared.cacheCodableWrapperConstruct(construct, propertyKey: propertyKey)
    }

    public var wrappedValue: Value {
        get { storedValue ?? construct.defaultValue }
        set { storedValue = newValue }
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Value.self) {
            self.storedValue = value
            // 临时构造一个
            self.construct = Construct(defaultValue: value)
        } else {
            throw DecodingError.valueNotFound(Value.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Expected \(Value.self) but found null value instead."))
        }
    }

    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
}

// MARK: - KeyedDecodingContainer

public extension KeyedDecodingContainer {
    ///
    /// Decodes successfully if key is available if not fallsback to the default value provided.
    func decode<P>(_: CodableWrapper<P>.Type, forKey key: Key) throws -> CodableWrapper<P> {
        guard let construct = CodableWrapperCache.shared.getCodableWrapperConstruct(type: P.self, propertyKey: key.stringValue) else {
            throw DecodingError.valueNotFound(P.self, DecodingError.Context(codingPath: [key], debugDescription: "Not exists CodableWrapperConstruct."))
        }
        if let value = try? decodeIfPresent(CodableWrapper<P>.self, forKey: key) {
            // 替换 construct
            value.construct = construct
            return value
        }
        return CodableWrapper<P>(key.stringValue, construct: construct)
    }
}
