//
//  LosslessEncodable.swift
//  CodableWrapper
//
//  Created by PAN on 2021/10/27.
//

import Foundation

public extension LosslessEncodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: AnyCodingKey.self)

        var _mirror: Mirror? = Mirror(reflecting: self)
        while let mirror = _mirror {
            for child in mirror.children {
                if let anyCodec = child.value as? AnyCodec,
                   let label = child.label, label.hasPrefix("_"),
                   let codingKey = AnyCodingKey(stringValue: String(label.dropFirst()))
                {
                    try anyCodec._encode(to: &container, forKey: codingKey)
                }
            }
            _mirror = mirror.superclassMirror
        }
    }
}
