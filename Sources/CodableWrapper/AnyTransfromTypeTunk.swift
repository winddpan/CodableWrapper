//
//  TransfromTypeTunk.swift
//  CodableWrapper
//
//  Created by PAN on 2021/7/30.
//

import Foundation

struct AnyTransfromTypeTunk {
    let hashValue: Int
    let fromNull: (() -> Any)?
    let fromJSON: ((Any?) -> Any)?
    let toJSON: ((Any) -> Encodable?)?

    init<T: TransformType>(_ raw: T) {
        fromNull = raw.fromNull
        fromJSON = raw.fromJSON
        toJSON = { obj in
            if let obj = obj as? T.Value {
                return raw.toJSON?(obj)
            }
            return nil
        }
        hashValue = raw.hashValue
    }
}
