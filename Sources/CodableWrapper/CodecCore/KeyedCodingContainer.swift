//
//  KeyedCodingContainer.swift
//  CodableWrapper
//
//  Created by xubin on 2021/7/15.
//

import Foundation

// MARK: - KeyedDecodingContainer

public extension KeyedDecodingContainer {
    /// for non-Codable type
    func decode<Value>(_ type: Codec<Value>.Type, forKey key: Key) throws -> Codec<Value> {
        return try _decode(type, forKey: key)
    }

    func decode<Value: Decodable>(_ type: Codec<Value>.Type, forKey key: Key) throws -> Codec<Value> {
        return try _decode(type, forKey: key)
    }

    private func _decode<Value>(_: Codec<Value>.Type, forKey key: Key) throws -> Codec<Value> {
        let wrapper = Codec<Value>(unsafed: ())
        Thread.current.lastInjectionKeeper = InjectionKeeper(codec: wrapper) {
            var mutatingSelf = self
            wrapper.finalize(container: &mutatingSelf, forKey: key)
        }
        return wrapper
    }
}

// MARK: - KeyedEncodingContainer

public extension KeyedEncodingContainer {
    func encode<Value>(_ value: Codec<Value>, forKey key: Key) throws {
        let keyString = value.construct.codingKeys.first ?? key.stringValue
        guard let codingKey = AnyCodingKey(stringValue: keyString) else { return }
        var encodeValue: Encodable?
        let construct = value.construct
        if let toJSON = construct.transformer?.toJSON {
            if let transformed = toJSON(value.wrappedValue) {
                encodeValue = transformed as? Encodable
            }
        } else if let wrappedValue = value.wrappedValue as? Encodable {
            encodeValue = wrappedValue
        }
        if let encodeValue = encodeValue {
            var mutatingSelf = self
            try mutatingSelf.convertAsAnyCodingKey { _container in
                try encodeValue.encode(to: &_container, forKey: codingKey)
            }
        }
    }
}
