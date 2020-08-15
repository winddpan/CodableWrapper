//
//  CodableWrapper.swift
//  CodableWrapper
//
//  Created by PAN on 2020/7/16.
//  Copyright © 2020 YR. All rights reserved.
//

import Foundation

@propertyWrapper
public final class CodableWrapper<Value: Codable>: Codable {
    struct Construct {
        var codingKeys: [String]
        var defaultValue: Value
    }

    private var unsafeCreated: Bool
    fileprivate var construct: Construct!
    fileprivate var storedValue: Value?
    fileprivate var decoderInjetion: ((CodableWrapper<Value>) -> Void)?

    deinit {
        if !unsafeCreated, let lastWrapper = Thread.current.lastCodableWrapper as? CodableWrapper<Value> {
            lastWrapper.invokeAfterInjection(with: construct)
            Thread.current.lastCodableWrapper = nil
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
        get { storedValue ?? construct.defaultValue }
        set { storedValue = newValue }
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Value.self) {
            storedValue = value
            unsafeCreated = true
        } else {
            throw DecodingError.valueNotFound(Value.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: "Expected \(Value.self) but found null value instead."))
        }
    }

    public func encode(to encoder: Encoder) throws {
        // Do nothing, KeyedEncodingContainer extension has done dirty stuff
    }
}

// - KeyedEncodingContainer

public extension KeyedEncodingContainer {
    mutating func encode<T, Value>(_ value: T, forKey key: Key) throws where T: CodableWrapper<Value> {
        guard let encoder = _encoder(), let key = AnyCodingKey(stringValue: value.construct.codingKeys.first ?? key.stringValue) else { return }
        var container = encoder.container(keyedBy: AnyCodingKey.self)
        try value.wrappedValue.encode(to: &container, forKey: key)
    }
}

// - KeyedDecodingContainer

public extension KeyedDecodingContainer {
    func decode<Value>(_: CodableWrapper<Value>.Type, forKey key: Key) throws -> CodableWrapper<Value> {
        let injection: ((CodableWrapper<Value>) -> Void) = { wrapper in
            guard wrapper.storedValue == nil, let dictionary = self._containerDictionary() else { return }
            guard let decoder = self._decoder(),  let container = try? decoder.container(keyedBy: AnyCodingKey.self) else { return }

            for codingKey in [key.stringValue] + wrapper.construct.codingKeys {
                if let key = AnyCodingKey(stringValue: codingKey), let value = try? container.decode(Value.self, forKey: key) {
                    wrapper.storedValue = value
                    return
                }
                if let json = dictionary[codingKey] {
                    if let bridge = Value.self as? _BuiltInBridgeType.Type, let bridged = bridge._transform(from: json) as? Value {
                        wrapper.storedValue = bridged
                        return
                    }
                }
            }
        }
        var wrapper: CodableWrapper<Value>
        if let decodeIfPresent = try? decodeIfPresent(CodableWrapper<Value>.self, forKey: key) {
            wrapper = decodeIfPresent
        } else {
            wrapper = CodableWrapper<Value>(unsafed: ())
        }
        wrapper.decoderInjetion = injection
        Thread.current.lastCodableWrapper = wrapper
        return wrapper
    }
}
