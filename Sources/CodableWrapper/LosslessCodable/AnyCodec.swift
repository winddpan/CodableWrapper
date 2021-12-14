//
//  AnyCodec.swift
//  CodableWrapper
//
//  Created by PAN on 2021/10/27.
//

import Foundation

protocol AnyCodec {
    func _finalize<K>(from decoder: Decoder, container: inout KeyedDecodingContainer<K>, forKey key: KeyedDecodingContainer<K>.Key)
    func _encode<K>(to container: inout KeyedEncodingContainer<K>, forKey key: KeyedEncodingContainer<K>.Key) throws
}

extension Codec: AnyCodec {
    func _finalize<K>(from decoder: Decoder, container: inout KeyedDecodingContainer<K>, forKey key: KeyedDecodingContainer<K>.Key) {
        self.finalize(container: &container, forKey: key, rawStoredValue: self.wrappedValue)
    }
    
    func _encode<K>(to container: inout KeyedEncodingContainer<K>, forKey key: KeyedEncodingContainer<K>.Key) throws {
        try container.encode(self, forKey: key)
    }
}
