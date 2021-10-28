//
//  CodecFinalize.swift
//  CodableWrapper
//
//  Created by PAN on 2021/10/26.
//

import Foundation

extension Codec {
    func finalize<K: CodingKey>(from container: KeyedDecodingContainer<K>, forKey key: KeyedDecodingContainer<K>.Key, rawStoredValue: Value) {
        guard let construct = construct else { return }
        let dictionary = container._containerDictionary()
        let bridge = Value.self as? _BuiltInBridgeType.Type
        let transformFromJSON = construct.transformer?.fromJSON
        var keys = construct.codingKeys + [key.stringValue]
        keys += keys.compactMap { $0.snakeCamelConvert() }

        for codingKey in keys {
            let _json = dictionary[codingKey] ?? NestedKey(codingKey)?.fetchToDecodeJSON(from: dictionary)
            if let json = _json {
                if let transformFromJSON = transformFromJSON {
                    storedValue = transformFromJSON(json) as? Value
                    return
                }
                if let converted = json as? Value {
                    storedValue = converted
                    return
                }
                if let _bridged = bridge?._transform(from: json), let __bridged = _bridged as? Value {
                    storedValue = __bridged
                    return
                }
                if !(json is NSNull), let valueType = Value.self as? Decodable.Type {
                    if let key = KeyedDecodingContainer<K>.Key(stringValue: codingKey),
                       let value = try? valueType.decode(from: container, forKey: key) as? Value
                    {
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
