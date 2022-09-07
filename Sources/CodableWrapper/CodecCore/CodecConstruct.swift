//
//  CodecConstruct.swift
//  CodableWrapper
//
//  Created by PAN on 2021/8/3.
//

import Foundation

final class CodecConstruct<Value>: Hashable {
    var codingKeys: [String] = []
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

    init(codingKeys: [String], transformer: AnyTransfromTypeTunk? = nil) {
        self.safedInit = true
        self.codingKeys = codingKeys
        self.transformer = transformer
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.codingKeys)
        hasher.combine(self.transformer?.hashValue)
    }

    static func == (lhs: CodecConstruct, rhs: CodecConstruct) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
