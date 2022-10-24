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
                let firstKey = value.construct.codingKeys.first
                if case .nested(let array) = firstKey {
                    try encodeNestedKey(value: encodeValue, array: array, container: &_container)
                } else {
                    let keyName: String
                    if case .noNested(let key) = firstKey {
                        keyName = key
                    } else {
                        keyName = key.stringValue
                    }
                    try encodeNormakKey(value: encodeValue, key: keyName, container: &_container)
                }
            }
        }
    }

    private func encodeNestedKey(value: Encodable, array: [String], container: inout KeyedEncodingContainer<AnyCodingKey>) throws {
        var keyComps = array
        let lastKey = keyComps.removeLast()
        var nestedContainer: KeyedEncodingContainer<AnyCodingKey>? = container
        for keyComp in keyComps {
            nestedContainer = nestedContainer?.nestedContainer(keyedBy: AnyCodingKey.self, forKey: .init(stringValue: keyComp)!)
        }
        if var nestedContainer = nestedContainer {
            try encodeNormakKey(value: value, key: lastKey, container: &nestedContainer)
        }
    }

    private func encodeNormakKey(value: Encodable, key: String, container: inout KeyedEncodingContainer<AnyCodingKey>) throws {
        let codingKey = AnyCodingKey(stringValue: key)!
        try value.encode(to: &container, forKey: codingKey)
    }
}
