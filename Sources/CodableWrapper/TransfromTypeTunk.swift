//
//  TransfromTypeTunk.swift
//  CodableWrapper
//
//  Created by PAN on 2021/7/30.
//

import Foundation

struct TransfromTypeTunk<Object>: TransformType {
    let fromNull: (() -> Object)?
    let fromJSON: ((Any?) -> Object)?
    let toJSON: ((Object) -> Encodable?)?

    init<T: TransformType>(_ raw: T) where T.Object == Object {
        fromNull = raw.fromNull
        fromJSON = raw.fromJSON
        toJSON = raw.toJSON
    }
}
