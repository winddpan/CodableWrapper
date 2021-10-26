//
//  CodecFinalize.swift
//  CodableWrapper
//
//  Created by PAN on 2021/10/26.
//

import Foundation

extension Codec {
    func finalize(dictionary: [String: Any], key: String, rawStoredValue: Value, rawDecoding: ((String, Any) -> Value?)?) {
        guard let construct = construct else { return }
        let bridge = Value.self as? _BuiltInBridgeType.Type
        let transformFromJSON = construct.transformer?.fromJSON
        var keys = construct.codingKeys + [key]
        keys += keys.compactMap { $0.snakeCamelConvert() }

        for codingKey in keys {
            let _json = dictionary[codingKey] ?? NestedKey(codingKey)?.toDecodeResult(in: dictionary)
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
                if !(json is NSNull), let decoded = rawDecoding?(codingKey, json) {
                    storedValue = decoded
                    return
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
