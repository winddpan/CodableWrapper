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
    associatedtype JSON

    func transformFromJSON(_ json: JSON?) -> Object
    func transformToJSON(_ object: Object) -> JSON?
    func hashValue() -> Int
}
