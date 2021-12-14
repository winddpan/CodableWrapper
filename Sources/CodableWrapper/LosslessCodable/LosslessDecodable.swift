//
//  LosslessDecodable.swift
//  CodableWrapper
//
//  Created by PAN on 2021/10/27.
//

import Foundation

public extension LosslessDecodable {
    init(from decoder: Decoder) throws {
        self.init()
        try self._decode(from: decoder)
    }

    private func _decode(from decoder: Decoder) throws {
        var container = try decoder.container(keyedBy: AnyCodingKey.self)

        var _mirror: Mirror? = Mirror(reflecting: self)
        while let mirror = _mirror {
            for child in mirror.children {
                if let anyCodec = child.value as? AnyCodec,
                   let label = child.label, label.hasPrefix("_"),
                   let codingKey = AnyCodingKey(stringValue: String(label.dropFirst()))
                {
                    anyCodec._finalize(from: decoder, container: &container, forKey: codingKey)
                }
            }
            _mirror = mirror.superclassMirror
        }
    }
}
