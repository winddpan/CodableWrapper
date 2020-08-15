//
//  TransformWrapper.swift
//  CodableWrapperDev
//
//  Created by winddpan on 2020/8/15.
//  Copyright © 2020 YR. All rights reserved.
//

import Foundation

@propertyWrapper
public final class TransformWrapper<Value>: Codable {
    struct Construct {
        var codingKeys: [String]
        var fromNil: () -> Value
        var fromJSON: (Any) -> Value?
        var toJSON: (Value) -> Encodable?
    }

    private var unsafeCreated: Bool
    fileprivate var construct: Construct!
    fileprivate var storedValue: Value?
    fileprivate var decoderInjetion: ((TransformWrapper<Value>) -> Void)?

    deinit {
        if !unsafeCreated, let lastWrapper = Thread.current.lastTransformWrapper as? TransformWrapper<Value> {
            lastWrapper.invokeAfterInjection(with: construct)
            Thread.current.lastTransformWrapper = nil
        }
    }

    init(construct: Construct) {
        unsafeCreated = false
        self.construct = construct
    }

    init(storedValue: Value) {
        unsafeCreated = false
        self.storedValue = storedValue
    }

    fileprivate init(unsafed: ()) {
        unsafeCreated = true
    }

    private func invokeAfterInjection(with construct: Construct) {
        self.construct = construct
        decoderInjetion?(self)
        decoderInjetion = nil
    }

    public var wrappedValue: Value {
        get { storedValue ?? construct.fromNil() }
        set { storedValue = newValue }
    }

    public required init(from decoder: Decoder) throws {
        unsafeCreated = true
    }

    public func encode(to encoder: Encoder) throws {
        // Do nothing, KeyedEncodingContainer extension has done dirty stuff
    }
}

// - KeyedEncodingContainer

public extension KeyedEncodingContainer {
    mutating func encode<T, Value>(_ value: T, forKey key: Key) throws where T: TransformWrapper<Value> {
        if let json = value.construct.toJSON(value.wrappedValue) {
            if let dictionary = _container() {
                dictionary.setValue(json, forKey: value.construct.codingKeys.first ?? key.stringValue)
            }
        } else {
            if let encoder = _encoder(), let key = AnyCodingKey(stringValue: value.construct.codingKeys.first ?? key.stringValue), let wrappedValue = value.wrappedValue as? Encodable {
                var container = encoder.container(keyedBy: AnyCodingKey.self)
                try? wrappedValue.encode(to: &container, forKey: key)
            }
        }
    }
}

// - KeyedDecodingContainer

public extension KeyedDecodingContainer {
    func decode<Value>(_: TransformWrapper<Value>.Type, forKey key: Key) throws -> TransformWrapper<Value> {
        let injection: ((TransformWrapper<Value>) -> Void) = { wrapper in
            guard wrapper.storedValue == nil, let dictionary = self._containerDictionary() else { return }
            for codingKey in [key.stringValue] + wrapper.construct.codingKeys {
                if let json = dictionary[codingKey] {
                    wrapper.storedValue = wrapper.construct.fromJSON(json)
                    return
                }
            }
            wrapper.storedValue = wrapper.construct.fromNil()
        }
        var wrapper: TransformWrapper<Value>
        if let decodeIfPresent = try? decodeIfPresent(TransformWrapper<Value>.self, forKey: key) {
            wrapper = decodeIfPresent
        } else {
            wrapper = TransformWrapper<Value>(unsafed: ())
        }
        wrapper.decoderInjetion = injection
        Thread.current.lastTransformWrapper = wrapper
        return wrapper
    }
}
