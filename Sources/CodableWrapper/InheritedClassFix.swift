//
//  InheritedClassFix.swift
//  CodableWrapper
//
//  Created by PAN on 2021/10/26.
//

import Foundation

public extension JSONDecoder {
    func decodeInheritedClass<T: AnyObject>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        let result = try self.decode(T.self, from: data)

        // fix subclass properties
        lazy var dictionary = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        var _mirror: Mirror? = Mirror(reflecting: result)
        while let mirror = _mirror, !mirror.isRootClassConfirmsDecodable {
            for child in mirror.children {
                if let anyCodec = child.value as? AnyCodec, let label = child.label, label.hasPrefix("_"), let dictionary = dictionary {
                    anyCodec.fixSubclassProperty(from: dictionary, key: String(label.dropFirst()), rawCodec: child.value)
                }
            }
            _mirror = mirror.superclassMirror
        }
        return result
    }
}

private extension Mirror {
    var isRootClassConfirmsDecodable: Bool {
        if subjectType is Decodable.Type, superclassMirror == nil || !(superclassMirror!.subjectType is Decodable.Type) {
            return true
        }
        return false
    }
}

private protocol AnyCodec {
    func fixSubclassProperty(from: [String: Any], key: String, rawCodec: Any)
}

extension Codec: AnyCodec {
    func fixSubclassProperty(from: [String: Any], key: String, rawCodec: Any) {
        if let wrapper = rawCodec as? Codec<Value> {
            self.finalize(dictionary: from, key: key, rawStoredValue: wrapper.wrappedValue, rawDecoding: nil)
        }
    }
}
