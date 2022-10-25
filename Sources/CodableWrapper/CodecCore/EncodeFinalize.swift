//
//  EncodeFinalize.swift
//
//
//  Created by PAN on 2022/10/24.
//

import Foundation

extension Codec {
    func encodeFinalize<K: CodingKey>(container: inout KeyedEncodingContainer<K>, forKey key: KeyedEncodingContainer<K>.Key) throws {
        let value = self
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
            try container.convertAsAnyCodingKey { _container in
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
