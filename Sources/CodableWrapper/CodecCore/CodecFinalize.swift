//
//  CodecFinalize.swift
//  CodableWrapper
//
//  Created by PAN on 2021/10/26.
//

import Foundation

extension Codec {
    func finalize<K: CodingKey>(container: inout KeyedDecodingContainer<K>, forKey key: KeyedDecodingContainer<K>.Key, rawStoredValue: Value) {
        guard let construct = construct else {
            storedValue = rawStoredValue
            return
        }

        let bridge = Value.self as? _BuiltInBridgeType.Type
        let transformFromJSON = construct.transformer?.fromJSON
        var keys = construct.codingKeys + [key.stringValue]
        keys += keys.compactMap { $0.snakeCamelConvert() }

        let transformer = ContainerTransformer(decode: &container)
        let _container = transformer.convertDecodingContainer()
        defer {
            transformer.convertBackDecodingContainer()
        }

        for __key in keys {
            guard let _key = AnyCodingKey(stringValue: __key) else {
                continue
            }
            let value = try? _container.decodeIfPresent(AnyDecodable.self, forKey: _key)?.value
            if let value = value {
                if let transformFromJSON = transformFromJSON {
                    storedValue = transformFromJSON(value) as? Value
                    return
                }
                if let converted = value as? Value {
                    storedValue = converted
                    return
                }
                if let _bridged = bridge?._transform(from: value), let __bridged = _bridged as? Value {
                    storedValue = __bridged
                    return
                }
                if let valueType = Value.self as? Decodable.Type {
                    if let value = try? valueType.decode(from: _container, forKey: _key) as? Value {
                        storedValue = value
                        return
                    }
                }
            }
        }
        if let transformFromJSON = transformFromJSON, let transformedNil = transformFromJSON(nil) as? Value {
            storedValue = transformedNil
            return
        }
        storedValue = rawStoredValue
    }
}
