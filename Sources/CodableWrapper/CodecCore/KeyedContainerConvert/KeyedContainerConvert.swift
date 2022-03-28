//
//  ContainerTransformer.swift
//  CodableWrapper
//
//  Created by PAN on 2021/12/14.
//

import Foundation

extension KeyedDecodingContainer {
    mutating func convertAsAnyCodingKey(_ handler: (inout KeyedDecodingContainer<AnyCodingKey>) throws -> Void) throws {
        if let modifier = KeyedContainerMap.shared.decodingContainerModifier(for: self) {
            try modifier.convert(target: &self, handler: handler)
        } else {
            throw KeyedContainerConvertError.unregistered
        }
    }
}

extension KeyedEncodingContainer {
    mutating func convertAsAnyCodingKey(_ handler: (inout KeyedEncodingContainer<AnyCodingKey>) throws -> Void) throws {
        if let modifier = KeyedContainerMap.shared.encodingContainerModifier(for: self) {
            try modifier.convert(target: &self, handler: handler)
        } else {
            throw KeyedContainerConvertError.unregistered
        }
    }
}
