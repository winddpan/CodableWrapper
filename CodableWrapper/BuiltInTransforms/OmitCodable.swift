//
//  OmitCodable.swift
//  CodableWrapper
//
//  Created by PAN on 2020/8/21.
//

import Foundation

public protocol OmitCodable {
    associatedtype Object
    init(defaultValue: Object)
}

public extension OmitCodable {
    init<Wrapped>() where Object == Wrapped? {
        self.init(defaultValue: nil)
    }
}

public struct OmitCoding<Object>: OmitCodable, TransformType {
    private let defaultValue: Object

    public func fromNull() -> Object {
        return defaultValue
    }

    public func fromJSON(_ json: Any) -> TransformTypeResult<Object?> {
        return .custom(nil)
    }

    public func toJSON(_ object: Object) -> TransformTypeResult<Encodable?> {
        return .custom(nil)
    }

    public init(defaultValue: Object) {
        self.defaultValue = defaultValue
    }
}

public struct OmitEncoding<Object>: OmitCodable, TransformType {
    private let defaultValue: Object

    public func fromNull() -> Object {
        return defaultValue
    }

    public func fromJSON(_ json: Any) -> TransformTypeResult<Object?> {
        return .default
    }

    public func toJSON(_ object: Object) -> TransformTypeResult<Encodable?> {
        return .custom(nil)
    }

    public init(defaultValue: Object) {
        self.defaultValue = defaultValue
    }
}

public struct OmitDecoding<Object>: OmitCodable, TransformType {
    private let defaultValue: Object

    public func fromNull() -> Object {
        return defaultValue
    }

    public func fromJSON(_ json: Any) -> TransformTypeResult<Object?> {
        return .custom(nil)
    }

    public func toJSON(_ object: Object) -> TransformTypeResult<Encodable?> {
        return .default
    }

    public init(defaultValue: Object) {
        self.defaultValue = defaultValue
    }
}
