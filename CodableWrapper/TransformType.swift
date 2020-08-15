//
//  Transform.swift
//  CodableWrapperDev
//
//  Created by winddpan on 2020/8/15.
//  Copyright © 2020 YR. All rights reserved.
//

import Foundation

public protocol TransformType {
    associatedtype Object
    func fromNil() -> Object
    func fromJSON(_ json: Any) -> Object?
    func toJSON(_ object: Object) -> Encodable?
}
