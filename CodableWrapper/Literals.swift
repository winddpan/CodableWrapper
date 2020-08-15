//
//  CodableWrapperLiterals.swift
//  CodableWrapperDev
//
//  Created by PAN on 2020/8/14.
//  Copyright © 2020 YR. All rights reserved.
//

import Foundation

extension CodableWrapper: ExpressibleByArrayLiteral where Value: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = Value.ArrayLiteralElement
    public convenience init(arrayLiteral elements: Value.ArrayLiteralElement...) {
        typealias Function = ([Value.ArrayLiteralElement]) -> Value
        let cast = unsafeBitCast(Value.init(arrayLiteral:), to: Function.self)
        self.init(storedValue: cast(elements))
    }
}

extension CodableWrapper: ExpressibleByNilLiteral where Value: ExpressibleByNilLiteral {
    public convenience init(nilLiteral: ()) {
        self.init(storedValue: nil)
    }
}

extension CodableWrapper: ExpressibleByFloatLiteral where Value: ExpressibleByFloatLiteral {
    public convenience init(floatLiteral value: Value.FloatLiteralType) {
        self.init(storedValue: Value(floatLiteral: value))
    }
}

extension CodableWrapper: ExpressibleByIntegerLiteral where Value: ExpressibleByIntegerLiteral {
    public convenience init(integerLiteral value: Value.IntegerLiteralType) {
        self.init(storedValue: Value(integerLiteral: value))
    }
}

extension CodableWrapper: ExpressibleByBooleanLiteral where Value: ExpressibleByBooleanLiteral {
    public convenience init(booleanLiteral value: Value.BooleanLiteralType) {
        self.init(storedValue: Value(booleanLiteral: value))
    }
}

extension CodableWrapper: ExpressibleByUnicodeScalarLiteral where Value: ExpressibleByUnicodeScalarLiteral {
    public convenience init(unicodeScalarLiteral value: Value.UnicodeScalarLiteralType) {
        self.init(storedValue: Value(unicodeScalarLiteral: value))
    }
}

extension CodableWrapper: ExpressibleByExtendedGraphemeClusterLiteral where Value: ExpressibleByExtendedGraphemeClusterLiteral {
    public convenience init(extendedGraphemeClusterLiteral value: Value.ExtendedGraphemeClusterLiteralType) {
        self.init(storedValue: Value(extendedGraphemeClusterLiteral: value))
    }
}

extension CodableWrapper: ExpressibleByStringLiteral where Value: ExpressibleByStringLiteral {
    public convenience init(stringLiteral value: Value.StringLiteralType) {
        self.init(storedValue: Value(stringLiteral: value))
    }
}

extension TransformWrapper: ExpressibleByArrayLiteral where Value: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = Value.ArrayLiteralElement
    public convenience init(arrayLiteral elements: Value.ArrayLiteralElement...) {
        typealias Function = ([Value.ArrayLiteralElement]) -> Value
        let cast = unsafeBitCast(Value.init(arrayLiteral:), to: Function.self)
        self.init(storedValue: cast(elements))
    }
}

extension TransformWrapper: ExpressibleByNilLiteral where Value: ExpressibleByNilLiteral {
    public convenience init(nilLiteral: ()) {
        self.init(storedValue: nil)
    }
}

extension TransformWrapper: ExpressibleByFloatLiteral where Value: ExpressibleByFloatLiteral {
    public convenience init(floatLiteral value: Value.FloatLiteralType) {
        self.init(storedValue: Value(floatLiteral: value))
    }
}

extension TransformWrapper: ExpressibleByIntegerLiteral where Value: ExpressibleByIntegerLiteral {
    public convenience init(integerLiteral value: Value.IntegerLiteralType) {
        self.init(storedValue: Value(integerLiteral: value))
    }
}

extension TransformWrapper: ExpressibleByBooleanLiteral where Value: ExpressibleByBooleanLiteral {
    public convenience init(booleanLiteral value: Value.BooleanLiteralType) {
        self.init(storedValue: Value(booleanLiteral: value))
    }
}

extension TransformWrapper: ExpressibleByUnicodeScalarLiteral where Value: ExpressibleByUnicodeScalarLiteral {
    public convenience init(unicodeScalarLiteral value: Value.UnicodeScalarLiteralType) {
        self.init(storedValue: Value(unicodeScalarLiteral: value))
    }
}

extension TransformWrapper: ExpressibleByExtendedGraphemeClusterLiteral where Value: ExpressibleByExtendedGraphemeClusterLiteral {
    public convenience init(extendedGraphemeClusterLiteral value: Value.ExtendedGraphemeClusterLiteralType) {
        self.init(storedValue: Value(extendedGraphemeClusterLiteral: value))
    }
}

extension TransformWrapper: ExpressibleByStringLiteral where Value: ExpressibleByStringLiteral {
    public convenience init(stringLiteral value: Value.StringLiteralType) {
        self.init(storedValue: Value(stringLiteral: value))
    }
}
