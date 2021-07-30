//
//  CodableWrapper.swift
//  CodableWrapper
//
//  Created by winddpan on 2020/8/15.
//

import Foundation

@propertyWrapper
public final class Codec<Value>: Codable {
    class Construct {
        var codingKeys: [String] = []
        var transformer: TransfromTypeTunk<Value>?

        init(codingKeys: [String], transformer: TransfromTypeTunk<Value>?) {
            self.codingKeys = codingKeys
            self.transformer = transformer
        }
    }

    var storedValue: Value?
    var construct: Construct!

    public var wrappedValue: Value {
        get { storedValue! }
        set { storedValue = newValue }
    }

    deinit {
        if let lastKeeper = Thread.current.lastInjectionKeeper as? InjectionKeeper<Value> {
            lastKeeper.codec.invokeAfterInjection(injection: lastKeeper.injection, from: self)
            Thread.current.lastInjectionKeeper = nil
        }
    }

    @available(*, unavailable, message: "Provide a default value or use optional Type")
    public init() {
        fatalError()
    }

    public required init(from decoder: Decoder) throws {}

    init(unsafed: ()) {}

    init(codingKeys: [String], defaultValue: Value, transformer: TransfromTypeTunk<Value>? = nil) {
        self.construct = Construct(codingKeys: codingKeys, transformer: transformer)
        self.wrappedValue = defaultValue
    }

    private func invokeAfterInjection(injection: (Codec<Value>) -> Void, from last: Codec<Value>) {
        construct = last.construct
        injection(self)
        
        if storedValue == nil {
            storedValue = last.wrappedValue
        }
    }

    // Do nothing, KeyedEncodingContainer extension has done dirty stuff
    public func encode(to encoder: Encoder) throws {}
}
