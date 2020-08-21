//
//  TransformOf.swift
//  CodableWrapperDev
//
//  Created by winddpan on 2020/8/15.
//  Copyright © 2020 YR. All rights reserved.
//

import Foundation

open class TransformOf<Object, JSON: Codable>: TransformType {
    private let _fromNull: () -> Object
    private let _fromJSON: ((JSON) -> Object?)?
    private let _toJSON: ((Object) -> JSON?)?

    public init(fromNull: @escaping () -> Object, fromJSON: ((JSON) -> Object?)? = nil, toJSON: ((Object) -> JSON?)? = nil) {
        _fromNull = fromNull
        _fromJSON = fromJSON
        _toJSON = toJSON
    }

    open func fromNull() -> Object {
        _fromNull()
    }

    open func fromJSON(_ json: Any) -> TransformTypeResult<Object?> {
        if let json = json as? JSON, let _fromJSON = _fromJSON {
            return .custom(_fromJSON(json))
        }
        return .default
    }

    open func toJSON(_ object: Object) -> TransformTypeResult<Encodable?> {
        if let _toJSON = _toJSON {
            return .custom(_toJSON(object))
        }
        return .default
    }
}
