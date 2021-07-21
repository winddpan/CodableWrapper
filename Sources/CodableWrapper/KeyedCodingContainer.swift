//
//  KeyedCodingContainer.swift
//  CodableWrapper
//
//  Created by xubin on 2021/7/15.
//

import Foundation

// MARK: - KeyedEncodingContainer

public extension KeyedEncodingContainer {
    
    mutating func encode<T, Value>(_ value: T, forKey key: Key) throws where T: CodableWrapper<Value> {
        if let encoder = _encoder(), let key = AnyCodingKey(stringValue: value.codingKeys.first ?? key.stringValue), let wrappedValue = value.wrappedValue as? Encodable {
            var container = encoder.container(keyedBy: AnyCodingKey.self)
            try wrappedValue.encode(to: &container, forKey: key)
        } else if let encoder = _encoder(), let key = AnyCodingKey(stringValue: key.stringValue), let wrappedValue = value.wrappedValue as? Encodable {
            var container = encoder.container(keyedBy: AnyCodingKey.self)
            try wrappedValue.encode(to: &container, forKey: key)
        }
    }
}

// MARK: - KeyedDecodingContainer

public extension KeyedDecodingContainer {
    /// for non-Codable type
    func decode<Value>(_ type: CodableWrapper<Value>.Type, forKey key: Key) throws -> CodableWrapper<Value> {
        return try _decode(type, forKey: key) { (_, _) -> Value? in
            nil
        }
    }

    func decode<Value: Decodable>(_ type: CodableWrapper<Value>.Type, forKey key: Key) throws -> CodableWrapper<Value> {
        return try _decode(type, forKey: key) { (container, key) -> Value? in
            if let key = AnyCodingKey(stringValue: key), let value = try? container.decode(Value.self, forKey: key) {
                return value
            }
            return nil
        }
    }

    private func _decode<Value>(_ type: CodableWrapper<Value>.Type, forKey key: Key, onDecoding: @escaping ((KeyedDecodingContainer<AnyCodingKey>, String) -> Value?)) throws -> CodableWrapper<Value> {
        let injection: CodableWrapper<Value>.DecoderInjection = { wrapper, customKeys in
            guard let dictionary = _containerDictionary() else { return }
            let keys = customKeys + [key.stringValue]
            
            var resolved = false
            if let decoder = self._decoder(), let container = try? decoder.container(keyedBy: AnyCodingKey.self) {
                for codingKey in keys {
                    if let decoded = onDecoding(container, codingKey) {
                        wrapper.wrappedValue = decoded
                        resolved = true
                        break
                    }
                }
            }
            
            if !resolved, let bridge = Value.self as? _BuiltInBridgeType.Type {
                for codingKey in keys {
                    guard let json = dictionary[codingKey] else { continue }
                    if let bridged = bridge._transform(from: json) as? Value {
                        wrapper.wrappedValue = bridged
                        resolved = true
                        break
                    }
                }
            }
        }

        var wrapper: CodableWrapper<Value>
        if let decodeIfPresent = try? decodeIfPresent(CodableWrapper<Value>.self, forKey: key) {
            wrapper = decodeIfPresent
        } else {
            wrapper = CodableWrapper<Value>(unsafed: ())
        }

        wrapper.decoderInjection = injection
        Thread.current.lastCodableWrapper = wrapper
        return wrapper
    }
}
