//
//  TransfromTypeTunk.swift
//  CodableWrapper
//
//  Created by PAN on 2021/7/30.
//

import Foundation

struct AnyTransfromTypeTunk {
    let hashValue: Int
    let fromJSON: (Any?) -> Any
    let toJSON: (Any) -> Any?

    init<T: TransformType>(_ raw: T) {
        fromJSON = { json in
            raw.transformFromJSON(json as? T.JSON)
        }
        toJSON = { object in
            if let object = object as? T.Object {
                return raw.transformToJSON(object)
            }
            return nil
        }
        hashValue = raw.hashValue()
    }
}
