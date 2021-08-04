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
                let dictionary = _container()
                dictionary.setValue(transformed, forKey: codingKey)
            }
        } else if let key = AnyCodingKey(stringValue: codingKey), let wrappedValue = value.wrappedValue as? Encodable {
            let encoder = _encoder()
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
        let injection: InjectionKeeper<Value>.InjectionClosure = { wrapper, storedValue in
            guard let construct = wrapper.construct else { return }
            let keys = wrapper.construct.codingKeys + [key.stringValue]
            let container = try? self._decoder().container(keyedBy: AnyCodingKey.self)
            let bridge = Value.self as? _BuiltInBridgeType.Type
            let dictionary = self._containerDictionary()

            for codingKey in keys {
                if let json = dictionary[codingKey] {
                    if let fromJSON = construct.transformer?.fromJSON {
                        wrapper.storedValue = fromJSON(json) as? Value
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
                wrapper.storedValue = fromNull() as? Value
                return
            }
            wrapper.storedValue = storedValue
        }
        let wrapper = Codec<Value>(unsafed: ())
        Thread.current.lastInjectionKeeper = InjectionKeeper(codec: wrapper, injection: injection)
        return wrapper
    }
}
