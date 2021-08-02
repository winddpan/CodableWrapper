//
//  InjectionKeeper.swift
//  CodableWrapper
//
//  Created by winddpan on 2020/8/15.
//

import Foundation

class InjectionKeeper<Value> {
    typealias InjectionClosure = (Codec<Value>, Value) -> Void

    let codec: Codec<Value>
    let injection: InjectionClosure

    init(codec: Codec<Value>, injection: @escaping InjectionClosure) {
        self.codec = codec
        self.injection = injection
    }
}

private var keeperKey: Void?

extension Thread {
    var lastInjectionKeeper: AnyObject? {
        set {
            objc_setAssociatedObject(self, &keeperKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, &keeperKey) as AnyObject
        }
    }
}
