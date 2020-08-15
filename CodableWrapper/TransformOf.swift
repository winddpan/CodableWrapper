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

    open func fromJSON(_ json: Any) -> Object? {
        if let json = json as? JSON {
            return _fromJSON?(json)
        }
        return nil
    }

    open func toJSON(_ object: Object) -> Encodable? {
        return _toJSON?(object)
    }
}
