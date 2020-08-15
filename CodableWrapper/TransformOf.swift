//
//  TransformOf.swift
//  CodableWrapperDev
//
//  Created by winddpan on 2020/8/15.
//  Copyright © 2020 YR. All rights reserved.
//

import Foundation

open class TransformOf<Object, JSON: Codable>: TransformType {
    private let _fromNil: () -> Object
    private let _fromJSON: ((JSON) -> Object?)?
    private let _toJSON: ((Object) -> JSON?)?

    public init(fromNil: @escaping () -> Object, fromJSON: ((JSON) -> Object?)? = nil, toJSON: ((Object) -> JSON?)? = nil) {
        self._fromNil = fromNil
        self._fromJSON = fromJSON
        self._toJSON = toJSON
    }

    open func fromNil() -> Object {
        _fromNil()
    }

    open func fromJSON(_ json: Any) -> TransfromTypeResult<Object?> {
        if let json = json as? JSON, let _fromJSON = _fromJSON {
            return .result(_fromJSON(json))
        }
        return .unImplement
    }

    open func toJSON(_ object: Object) -> TransfromTypeResult<Encodable?> {
        if let _toJSON = _toJSON {
            return .result(_toJSON(object))
        }
        return .unImplement
    }
}
