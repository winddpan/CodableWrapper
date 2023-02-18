//
//  CodableWrapper.swift
//  CodableWrapper
//
//  Created by winddpan on 2020/8/15.
//

import Foundation

@propertyWrapper
public struct Codec<Value>: Codable {
    var construct: CodecConstruct<Value>

    public var wrappedValue: Value {
        get {
            return construct.storedValue!
        }
        set {
            if !isKnownUniquelyReferenced(&construct) {
                let newConstruct = CodecConstruct<Value>(unsafed: ())
                newConstruct.transferFrom(construct)
                construct = newConstruct
            }
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

extension Codec: Equatable where Value: Equatable {
    public static func == (lhs: Codec<Value>, rhs: Codec<Value>) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

extension Codec: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue)
    }
}
