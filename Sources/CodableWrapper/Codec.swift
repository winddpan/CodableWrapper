//
//  CodableWrapper.swift
//  CodableWrapper
//
//  Created by winddpan on 2020/8/15.
//

import Foundation

@propertyWrapper
public struct Codec<Value>: Codable {
    let construct: CodecConstruct<Value>

    public var wrappedValue: Value {
        get {
            construct.storedValue!
        }
        set {
            construct.storedValue = newValue
        }
    }

    @available(*, unavailable, message: "Provide a default value or use optional Type")
    public init() {
        fatalError()
    }

    public init(from _: Decoder) throws {
        construct = .init(unsafed: ())
    }

    init(unsafed _: ()) {
        construct = .init(unsafed: ())
    }

    init(defaultValue: Value?, construct: CodecConstruct<Value>) {
        self.construct = .init(codingKeys: construct.codingKeys, transformer: construct.transformer)
        self.construct.storedValue = defaultValue
    }

    // Do nothing, KeyedEncodingContainer extension has done dirty stuff
    public func encode(to _: Encoder) throws {}
}

extension Codec: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        "\(wrappedValue)"
    }

    public var debugDescription: String {
        "\(wrappedValue)"
    }
}
