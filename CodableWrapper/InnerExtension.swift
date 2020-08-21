//
//  InnerExtension.swift
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

extension KeyedEncodingContainer {
    func _encoder() -> Encoder? {
        let mirror0 = Mirror(reflecting: self)
        let mirror1 = Mirror(reflecting: mirror0.children.first!.value)
        let mirror2 = Mirror(reflecting: mirror1.children.first!.value)
        if let encoder = mirror2.children.first(where: { $0.label == "encoder" })?.value as? Encoder {
            return encoder
        }
        return nil
    }

    func _container() -> NSMutableDictionary? {
        let mirror0 = Mirror(reflecting: self)
        let mirror1 = Mirror(reflecting: mirror0.children.first!.value)
        let mirror2 = Mirror(reflecting: mirror1.children.first!.value)
        if let container = mirror2.children.first(where: { $0.label == "container" })?.value as? NSMutableDictionary {
            return container
        }
        return nil
    }
}

extension KeyedDecodingContainer {
    func _decoder() -> Decoder? {
        let mirror0 = Mirror(reflecting: self)
        let mirror1 = Mirror(reflecting: mirror0.children.first!.value)
        let mirror2 = Mirror(reflecting: mirror1.children.first!.value)
        if let decoder = mirror2.children.first(where: { $0.label == "decoder" })?.value as? Decoder {
            return decoder
        }
        return nil
    }

    func _containerDictionary() -> [String: Any]? {
        let mirror0 = Mirror(reflecting: self)
        let mirror1 = Mirror(reflecting: mirror0.children.first!.value)
        let mirror2 = Mirror(reflecting: mirror1.children.first!.value)
        if let container = mirror2.children.first(where: { $0.label == "container" })?.value as? [String: Any] {
            return container
        }
        return nil
    }
}

private extension Mirror {
    func debug(_ parent: String) {
        for child in children {
            if let label = child.label {
                print("\(parent) -> \(label)")
                let nodeMirror = Mirror(reflecting: child.value)
                nodeMirror.debug(label)
            }
        }
    }
}
