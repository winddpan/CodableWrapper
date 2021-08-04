//
//  EncodableExtension.swift
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
