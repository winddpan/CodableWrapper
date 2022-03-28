//
//  CodableExtension.swift
//  CodableWrapper
//
//  Created by winddpan on 2020/8/16.
//

import Foundation

extension Encodable {
    func encode<K>(to container: inout KeyedEncodingContainer<K>, forKey key: KeyedEncodingContainer<K>.Key) throws {
        try container.encode(self, forKey: key)
    }
}

extension Decodable {
    static func decode<K>(from container: KeyedDecodingContainer<K>, forKey key: KeyedDecodingContainer<K>.Key) throws -> Self {
        return try container.decode(Self.self, forKey: key)
    }
}
