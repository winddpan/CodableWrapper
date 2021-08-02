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
            Self.invokeAfterInjection(injection: lastKeeper.injection, new: lastKeeper.codec, last: self)
            Thread.current.lastInjectionKeeper = nil
        }
    }

    @available(*, unavailable, message: "Provide a default value or use optional Type")
    public init() {
        fatalError()
    }

    public required init(from decoder: Decoder) throws {}

    init(unsafed: ()) {}

    init(defaultValue: Value, construct: Construct) {
        self.construct = construct
        self.wrappedValue = defaultValue
    }

    // Do nothing, KeyedEncodingContainer extension has done dirty stuff
    public func encode(to encoder: Encoder) throws {}

    private class func invokeAfterInjection(injection: InjectionKeeper<Value>.InjectionClosure, new: Codec<Value>, last: Codec<Value>) {
        new.construct = last.construct
        injection(new, last.wrappedValue)
    }
}
