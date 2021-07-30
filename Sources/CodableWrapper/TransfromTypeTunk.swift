//
//  TransfromTypeTunk.swift
//  CodableWrapper
//
//  Created by PAN on 2021/7/30.
//

import Foundation

struct TransfromTypeTunk<Value>: TransformType {
    let fromNull: (() -> Value)?
    let fromJSON: ((Any?) -> Value)?
    let toJSON: ((Value) -> Encodable?)?

    init<T: TransformType>(_ raw: T) where T.Value == Value {
        fromNull = raw.fromNull
        fromJSON = raw.fromJSON
        toJSON = raw.toJSON
    }

    init<T: TransformType>(_ raw: T) where T.Value? == Value {
        fromNull = raw.fromNull
        fromJSON = raw.fromJSON
        toJSON = { value in
            if let value = value {
                return raw.toJSON?(value)
            }
            return nil
        }
    }
}
