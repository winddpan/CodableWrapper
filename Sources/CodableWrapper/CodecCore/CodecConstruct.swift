//
//  CodecConstruct.swift
//  CodableWrapper
//
//  Created by PAN on 2021/8/3.
//

import Foundation

enum CodecConstructKey {
    case noNested(String)
    case nested([String])

    init(key: String, noNested: Bool) {
        if noNested {
            self = .noNested(key)
        } else {
            let comps = key.components(separatedBy: ".")
            if comps.count > 1 {
                self = .nested(comps)
            } else {
                self = .noNested(key)
            }
        }
    }
}

final class CodecConstruct<Value> {
    var codingKeys: [CodecConstructKey] = []
    var transformer: AnyTransfromTypeTunk?
    var storedValue: Value?
    let safedInit: Bool

    deinit {
        if safedInit, let lastKeeper = Thread.current.lastInjectionKeeper as? InjectionKeeper<Value> {
            lastKeeper.injectBack(self)
            Thread.current.lastInjectionKeeper = nil
        }
    }

    func transferFrom(_ other: CodecConstruct<Value>) {
        self.codingKeys = other.codingKeys
        self.transformer = other.transformer
        self.storedValue = other.storedValue
    }

    init(unsafed _: ()) {
        self.safedInit = false
    }

    init(codingKeys: [CodecConstructKey], transformer: AnyTransfromTypeTunk? = nil) {
        self.safedInit = true
        self.codingKeys = codingKeys
        self.transformer = transformer
    }
}
