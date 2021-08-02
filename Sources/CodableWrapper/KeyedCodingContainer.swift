//
//  KeyedCodingContainer.swift
//  CodableWrapper
//
//  Created by xubin on 2021/7/15.
//

import Foundation

// MARK: - KeyedEncodingContainer

public extension KeyedEncodingContainer {
    mutating func encode<T, Value>(_ value: T, forKey key: Key) throws where T: Codec<Value> {
        let codingKey = value.construct?.codingKeys.first ?? key.stringValue
        if let construct = value.construct, let toJSON = construct.transformer?.toJSON {
            if let transformed = toJSON(value.wrappedValue) {
                if let dictionary = _container() {
                    dictionary.setValue(transformed, forKey: codingKey)
                }
            }
        } else if let encoder = _encoder(), let key = AnyCodingKey(stringValue: codingKey), let wrappedValue = value.wrappedValue as? Encodable {
            var container = encoder.container(keyedBy: AnyCodingKey.self)
            try wrappedValue.encode(to: &container, forKey: key)
        }
    }
}

// MARK: - KeyedDecodingContainer

public extension KeyedDecodingContainer {
    /// for non-Codable type
    func decode<Value>(_ type: Codec<Value>.Type, forKey key: Key) throws -> Codec<Value> {
        return try _decode(type, forKey: key) { (_, _) -> Value? in
            nil
        }
    }

    func decode<Value: Decodable>(_ type: Codec<Value>.Type, forKey key: Key) throws -> Codec<Value> {
        return try _decode(type, forKey: key) { (container, key) -> Value? in
            if let key = AnyCodingKey(stringValue: key), let value = try? container.decode(Value.self, forKey: key) {
                return value
            }
            return nil
        }
    }

    private func _decode<Value>(_ type: Codec<Value>.Type, forKey key: Key, onDecoding: @escaping ((KeyedDecodingContainer<AnyCodingKey>, String) -> Value?)) throws -> Codec<Value> {
        let injection: ((Codec<Value>, Value) -> Void) = { wrapper, storedValue in
            guard let construct = wrapper.construct, let dictionary = self._containerDictionary() else { return }
            let keys = wrapper.construct.codingKeys + [key.stringValue]
            let container = try? self._decoder()?.container(keyedBy: AnyCodingKey.self)
            let bridge = Value.self as? _BuiltInBridgeType.Type

            for codingKey in keys {
                if let json = dictionary[codingKey] {
                    if let fromJSON = construct.transformer?.fromJSON {
                        wrapper.storedValue = fromJSON(json)
                        return
                    }
                    if let container = container, let decoded = onDecoding(container, codingKey) {
                        wrapper.storedValue = decoded
                        return
                    }
                    if let bridged = bridge?._transform(from: json) as? Value {
                        wrapper.storedValue = bridged
                        return
                    }
                }
            }
            if let fromNull = construct.transformer?.fromNull {
                wrapper.storedValue = fromNull()
                return
            }
            wrapper.storedValue = storedValue
        }

        var wrapper: Codec<Value>
        if let decodeIfPresent = try? decodeIfPresent(Codec<Value>.self, forKey: key) {
            wrapper = decodeIfPresent
        } else {
            wrapper = Codec<Value>(unsafed: ())
        }

        Thread.current.lastInjectionKeeper = InjectionKeeper(codec: wrapper, injection: injection)
        return wrapper
    }
}
