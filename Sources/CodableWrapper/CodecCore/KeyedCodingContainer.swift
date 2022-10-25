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
            try? wrapper.decodeFinalize(container: &mutatingSelf, forKey: key)
        }
        return wrapper
    }
}

// MARK: - KeyedEncodingContainer

public extension KeyedEncodingContainer {
    func encode<Value>(_ value: Codec<Value>, forKey key: Key) throws {
        var mutatingSelf = self
        try value.encodeFinalize(container: &mutatingSelf, forKey: key)
    }
}
