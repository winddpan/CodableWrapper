//
//  DecodeFinalize.swift
//  CodableWrapper
//
//  Created by PAN on 2021/10/26.
//

import Foundation

extension Codec {
    func decodeFinalize<K: CodingKey>(container: inout KeyedDecodingContainer<K>, forKey key: KeyedDecodingContainer<K>.Key) throws {
        let transformFromJSON = construct.transformer?.fromJSON
        var keys = construct.codingKeys
        keys.append(.noNested(key.stringValue))
        keys.append(contentsOf: keys.compactMap { key -> CodecConstructKey? in
            if case .noNested(let keyName) = key, let snakeCamelConvert = keyName.snakeCamelConvert() {
                return .noNested(snakeCamelConvert)
            }
            return nil
        })

        try container.convertAsAnyCodingKey { _container in
            for key in keys {
                switch key {
                case .noNested(let string):
                    if tryNormalKeyDecode(key: string, _container: &_container) {
                        return
                    }
                case .nested(let array):
                    if tryNestedKeyDecode(array: array, _container: &_container) {
                        return
                    }
                }
            }
            if let transformFromJSON = transformFromJSON, let transformedNil = transformFromJSON(nil) as? Value {
                construct.storedValue = transformedNil
                return
            }
        }
    }

    private func tryNormalKeyDecode(key: String, _container: inout KeyedDecodingContainer<AnyCodingKey>) -> Bool {
        let _key = AnyCodingKey(stringValue: key)!
        let value = try? _container.decodeIfPresent(AnyDecodable.self, forKey: _key)?.value
        if let value = value {
            if let transformFromJSON = construct.transformer?.fromJSON {
                construct.storedValue = transformFromJSON(value) as? Value
                return true
            }
            if let converted = value as? Value {
                construct.storedValue = converted
                return true
            }
            if let _bridged = (Value.self as? _BuiltInBridgeType.Type)?._transform(from: value), let __bridged = _bridged as? Value {
                construct.storedValue = __bridged
                return true
            }
            if let valueType = Value.self as? Decodable.Type {
                if let value = try? valueType.decode(from: _container, forKey: _key) as? Value {
                    construct.storedValue = value
                    return true
                }
            }
        }
        return false
    }

    private func tryNestedKeyDecode(array: [String], _container: inout KeyedDecodingContainer<AnyCodingKey>) -> Bool {
        var keyComps = array
        guard let rootKey = AnyCodingKey(stringValue: keyComps.removeFirst()) else {
            return false
        }
        var container: KeyedDecodingContainer<AnyCodingKey>?
        if let _container = try? _container.nestedContainer(keyedBy: AnyCodingKey.self, forKey: rootKey) {
            container = _container
            let lastKey = keyComps.removeLast()
            for keyComp in keyComps {
                container = try? container?.nestedContainer(keyedBy: AnyCodingKey.self, forKey: .init(stringValue: keyComp)!)
            }
            if var container = container {
                for key in [lastKey, lastKey.snakeCamelConvert()].compactMap({ $0 }) {
                    if tryNormalKeyDecode(key: key, _container: &container) {
                        return true
                    }
                }
            }
        }
        return false
    }
}
