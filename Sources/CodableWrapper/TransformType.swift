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
    var fromNull: (() -> Object)? { get }
    var fromJSON: ((Any?) -> Object)? { get }
    var toJSON: ((Object) -> Encodable?)? { get }
}
