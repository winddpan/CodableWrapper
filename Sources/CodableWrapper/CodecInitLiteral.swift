//
//  File.swift
//
//
//  Created by winddpan on 2022/8/1.
//

import Foundation

extension Codec: ExpressibleByNilLiteral where Value: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self.init(literalValue: nil)
    }
}

extension Codec: ExpressibleByArrayLiteral where Value: CodecOptionalProtocol, Value.Wrapped: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = Value.Wrapped.ArrayLiteralElement
    public init(arrayLiteral elements: ArrayLiteralElement...) {
        typealias Function = ([ArrayLiteralElement]) -> Value
        let cast = unsafeBitCast(Value.Wrapped.init(arrayLiteral:), to: Function.self)
        self.init(literalValue: cast(elements))
    }
}

extension Codec: ExpressibleByIntegerLiteral where Value: CodecOptionalProtocol, Value.Wrapped: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Value.Wrapped.IntegerLiteralType) {
        self.init(literalValue: Value.Wrapped(integerLiteral: value) as! Value)
    }
}

extension Codec: ExpressibleByFloatLiteral where Value: CodecOptionalProtocol, Value.Wrapped: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Value.Wrapped.FloatLiteralType) {
        self.init(literalValue: Value.Wrapped(floatLiteral: value) as! Value)
    }
}

extension Codec: ExpressibleByBooleanLiteral where Value: CodecOptionalProtocol, Value.Wrapped: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Value.Wrapped.BooleanLiteralType) {
        self.init(literalValue: Value.Wrapped(booleanLiteral: value) as! Value)
    }
}

extension Codec: ExpressibleByUnicodeScalarLiteral where Value: CodecOptionalProtocol, Value.Wrapped: ExpressibleByUnicodeScalarLiteral {
    public init(unicodeScalarLiteral value: Value.Wrapped.UnicodeScalarLiteralType) {
        self.init(literalValue: Value.Wrapped(unicodeScalarLiteral: value) as! Value)
    }
}

extension Codec: ExpressibleByExtendedGraphemeClusterLiteral where Value: CodecOptionalProtocol, Value.Wrapped: ExpressibleByExtendedGraphemeClusterLiteral {
    public init(extendedGraphemeClusterLiteral value: Value.Wrapped.ExtendedGraphemeClusterLiteralType) {
        self.init(literalValue: Value.Wrapped(extendedGraphemeClusterLiteral: value) as! Value)
    }
}

extension Codec: ExpressibleByStringLiteral where Value: CodecOptionalProtocol, Value.Wrapped: ExpressibleByStringLiteral {
    public init(stringLiteral value: Value.Wrapped.StringLiteralType) {
        self.init(literalValue: Value.Wrapped(stringLiteral: value) as! Value)
    }
}

private extension Codec {
    init(literalValue: Value) {
        self.init(defaultValue: literalValue, construct: CodecConstruct<Value>.init(codingKeys: []))
    }
}
