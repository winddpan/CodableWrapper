//
//  Transform.swift
//  CodableWrapperDev
//
//  Created by winddpan on 2020/8/15.
//  Copyright © 2020 YR. All rights reserved.
//

import Foundation

public protocol TransformType {
    associatedtype Value
    var fromNull: (() -> Value)? { get }
    var fromJSON: ((Any?) -> Value)? { get }
    var toJSON: ((Value) -> Encodable?)? { get }
    var hashValue: Int { get }
}
