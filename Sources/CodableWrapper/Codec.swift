//
//  CodableWrapper.swift
//  CodableWrapper
//
//  Created by winddpan on 2020/8/15.
//

import Foundation

@propertyWrapper
public final class Codec<Value>: Codable {
    typealias DecoderInjection = (_ target: Codec<Value>, _ customKeys: [String]) -> Void
    
    var storedValue: Value?
    var codingKeys: [String] = []
    var decoderInjection: DecoderInjection?
    
    public var wrappedValue: Value {
        get { storedValue! }
        set { storedValue = newValue }
    }

    deinit {
        if let value = storedValue, let lastWrapper = Thread.current.lastCodableWrapper as? Codec<Value> {
            lastWrapper.invokeAfterInjection(value: value, keys: codingKeys)
            Thread.current.lastCodableWrapper = nil
        }
    }

    @available(*, unavailable, message: "Provide a default value or use optional Type")
    public init() {
        fatalError()
    }
    
    public required init(from decoder: Decoder) throws {}

    init(unsafed: ()) {}
    
    init(codingKeys: [String], defaultValue: Value) {
        self.codingKeys = codingKeys
        self.wrappedValue = defaultValue
    }

    private func invokeAfterInjection(value: Value, keys: [String]) {
        decoderInjection?(self, keys)
        decoderInjection = nil
        
        codingKeys = keys
        if storedValue == nil {
            wrappedValue = value
        }
    }

    // Do nothing, KeyedEncodingContainer extension has done dirty stuff
    public func encode(to encoder: Encoder) throws {}
}
