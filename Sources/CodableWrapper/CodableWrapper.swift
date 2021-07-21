//
//  CodableWrapper.swift
//  CodableWrapper
//
//  Created by winddpan on 2020/8/15.
//

import Foundation

@propertyWrapper
public final class CodableWrapper<Value>: Codable {
    typealias DecoderInjection = (_ target: CodableWrapper<Value>, _ customKeys: [String]) -> Void
    
    var storedValue: Value?
    var codingKeys: [String] = []
    var decoderInjection: DecoderInjection?
    
    public var wrappedValue: Value {
        get { storedValue! }
        set { storedValue = newValue }
    }

    deinit {
        if let value = storedValue, let lastWrapper = Thread.current.lastCodableWrapper as? CodableWrapper<Value> {
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

    private func invokeAfterInjection(value: Value, keys: [String]) {
        decoderInjection?(self, keys)
        decoderInjection = nil
        if self.storedValue == nil {
            self.wrappedValue = value
        }
    }

    // Do nothing, KeyedEncodingContainer extension has done dirty stuff
    public func encode(to encoder: Encoder) throws {}
}
