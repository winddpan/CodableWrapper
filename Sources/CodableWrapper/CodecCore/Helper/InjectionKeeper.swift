//
//  InjectionKeeper.swift
//  CodableWrapper
//
//  Created by winddpan on 2020/8/15.
//

import Foundation

class InjectionKeeper<Value> {
    typealias InjectionClosure = (InjectionKeeper<Value>, Codec<Value>, Value) -> Void

    let codec: Codec<Value>
    let injection: InjectionClosure

    init(codec: Codec<Value>, injection: @escaping InjectionClosure) {
        self.codec = codec
        self.injection = injection
    }
}

private var keeperKey: Void?
private var keyedDecodingContainerKey: Void?

extension Thread {
    var lastInjectionKeeper: AnyObject? {
        set {
            objc_setAssociatedObject(self, &keeperKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, &keeperKey) as AnyObject?
        }
    }
}

extension Decoder {
    var lazyAnycodingKeyContainer: KeyedDecodingContainer<AnyCodingKey>? {
        if let cache = objc_getAssociatedObject(self, &keyedDecodingContainerKey) as? KeyedDecodingContainer<AnyCodingKey> {
            return cache
        }
        let result = try? self.container(keyedBy: AnyCodingKey.self)
        objc_setAssociatedObject(self, &keyedDecodingContainerKey, result, .OBJC_ASSOCIATION_RETAIN)
        return result
    }
}
