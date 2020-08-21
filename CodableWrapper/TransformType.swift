//
//  Transform.swift
//  CodableWrapperDev
//
//  Created by winddpan on 2020/8/15.
//  Copyright © 2020 YR. All rights reserved.
//

import Foundation

public enum TransformTypeResult<T> {
    case custom(T)
    case `default`
}

public protocol TransformType {
    associatedtype Object
    func fromNull() -> Object
    func fromJSON(_ json: Any) -> TransformTypeResult<Object?>
    func toJSON(_ object: Object) -> TransformTypeResult<Encodable?>
}
