//
//  InjectionKeeper.swift
//  CodableWrapper
//
//  Created by winddpan on 2020/8/15.
//

import Foundation

class InjectionKeeper<Value> {
    private let codec: Codec<Value>
    private let decoding: () -> Void

    init(codec: Codec<Value>, decoding: @escaping () -> Void) {
        self.codec = codec
        self.decoding = decoding
    }
    
    func injectBack(_ construct: CodecConstruct<Value>) {
        codec.construct.transferFrom(construct)
        decoding()
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
