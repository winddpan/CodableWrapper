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
                NestedKey(codingKey)?.replaceEncodeKey(in: dictionary)
            }
        } else if let key = AnyCodingKey(stringValue: codingKey), let wrappedValue = value.wrappedValue as? Encodable {
            var container = _encoder().container(keyedBy: AnyCodingKey.self)
            try wrappedValue.encode(to: &container, forKey: key)
            NestedKey(codingKey)?.replaceEncodeKey(in: _container())
        }
    }
}

// MARK: - KeyedDecodingContainer

public extension KeyedDecodingContainer {
    /// for non-Codable type
    func decode<Value>(_ type: Codec<Value>.Type, forKey key: Key) throws -> Codec<Value> {
        return try _decode(type, forKey: key, rawDecoding: nil)
    }

    func decode<Value: Decodable>(_ type: Codec<Value>.Type, forKey key: Key) throws -> Codec<Value> {
        return try _decode(type, forKey: key) { key, value -> Value? in
            if let key = AnyCodingKey(stringValue: key),
               let container = try? self._decoder().container(keyedBy: AnyCodingKey.self),
               let value = try? container.decode(Value.self, forKey: key)
            {
                return value
            }
            return nil
        }
    }

    private func _decode<Value>(_: Codec<Value>.Type, forKey key: Key, rawDecoding: ((String, Any) -> Value?)?) throws -> Codec<Value> {
        let injection: InjectionKeeper<Value>.InjectionClosure = { wrapper, storedValue in
            wrapper.finalize(dictionary: self._containerDictionary(), key: key.stringValue, rawStoredValue: storedValue, rawDecoding: rawDecoding)
        }
        let wrapper = Codec<Value>(unsafed: ())
        Thread.current.lastInjectionKeeper = InjectionKeeper(codec: wrapper, injection: injection)
        return wrapper
    }
}
