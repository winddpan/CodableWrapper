//
//  InjectionKeeper.swift
//  CodableWrapper
//
//  Created by winddpan on 2020/8/15.
//

import Foundation

class InjectionKeeper<Value> {
    let codec: Codec<Value>
    let injection: (Codec<Value>) -> Void

    init(codec: Codec<Value>, injection: @escaping (Codec<Value>) -> Void) {
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
