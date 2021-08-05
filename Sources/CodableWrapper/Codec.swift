//
//  CodableWrapper.swift
//  CodableWrapper
//
//  Created by winddpan on 2020/8/15.
//

import Foundation

private let constructCacheMapTable = NSMapTable<NSNumber, CodecConstruct>(keyOptions: .strongMemory, valueOptions: .weakMemory)

@propertyWrapper
public final class Codec<Value>: Codable {
    var storedValue: Value?
    private(set) var construct: CodecConstruct!

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

    public required init(from _: Decoder) throws {}

    init(unsafed _: ()) {}

    init(defaultValue: Value, construct: CodecConstruct) {
        let hashKey = NSNumber(value: construct.hashValue)
        let cacheConstruct = constructCacheMapTable.object(forKey: hashKey)
        if let cacheConstruct = cacheConstruct {
            self.construct = cacheConstruct
        } else {
            constructCacheMapTable.setObject(construct, forKey: hashKey)
            self.construct = construct
        }
        wrappedValue = defaultValue
    }

    // Do nothing, KeyedEncodingContainer extension has done dirty stuff
    public func encode(to _: Encoder) throws {}

    private class func invokeAfterInjection(injection: InjectionKeeper<Value>.InjectionClosure, new: Codec<Value>, last: Codec<Value>) {
        new.construct = last.construct
        injection(new, last.wrappedValue)
    }
}
