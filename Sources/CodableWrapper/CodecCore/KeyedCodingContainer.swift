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

    private func _decode<Value>(_ type: Codec<Value>.Type, forKey key: Key) throws -> Codec<Value> {
        let wrapper = Codec<Value>(unsafed: ())
        let injection: InjectionKeeper<Value>.InjectionClosure = { _, wrapper, storedValue in
            var mutatingSelf = self
            wrapper.finalize(container: &mutatingSelf, forKey: key, rawStoredValue: storedValue)
        }
        Thread.current.lastInjectionKeeper = InjectionKeeper(codec: wrapper, injection: injection)
        return wrapper
    }
}

// MARK: - KeyedEncodingContainer

public extension KeyedEncodingContainer {
    func encode<T, Value>(_ value: T, forKey key: Key) throws where T: Codec<Value> {
        let keyString = value.construct?.codingKeys.first ?? key.stringValue
        guard let codingKey = AnyCodingKey(stringValue: keyString) else { return }
        var encodeValue: Encodable?
        if let construct = value.construct, let toJSON = construct.transformer?.toJSON {
            if let transformed = toJSON(value.wrappedValue) {
                encodeValue = transformed as? Encodable
            }
        } else if let wrappedValue = value.wrappedValue as? Encodable {
            encodeValue = wrappedValue
        }
        if let encodeValue = encodeValue {
            var mutatingSelf = self
            let transformer = ContainerTransformer(encode: &mutatingSelf)
            var container = transformer.convertEncodingContainer()
            try encodeValue.encode(to: &container, forKey: codingKey)
            transformer.convertBackEncodingContainer()
        }
    }
}
