//
//  TransformOf.swift
//  CodableWrapperDev
//
//  Created by winddpan on 2020/8/15.
//  Copyright © 2020 YR. All rights reserved.
//

import Foundation

open class TransformOf<Object, JSON: Codable>: TransformType {
    open var fromNull: (() -> Object)?
    open var fromJSON: ((Any?) -> Object)?
    open var toJSON: ((Object) -> Encodable?)?

    public init(fromNull: @escaping (() -> Object), fromJSON: ((JSON) -> Object?)? = nil, toJSON: ((Object) -> JSON?)? = nil) {
        self.fromNull = fromNull
        self.fromJSON = { json in
            if let json = json as? JSON, let transfromed = fromJSON?(json) {
                return transfromed
            }
            return fromNull()
        }
        self.toJSON = toJSON
    }
}
