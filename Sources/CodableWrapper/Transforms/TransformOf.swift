//
//  TransformOf.swift
//  CodableWrapperDev
//
//  Created by winddpan on 2020/8/15.
//  Copyright © 2020 YR. All rights reserved.
//

import Foundation

open class TransformOf<Object, JSON>: TransformType {
    open var fromJSON: (JSON?) -> Object
    open var toJSON: (Object) -> JSON?
    open var hash: Int

    public init(fromJSON: @escaping ((JSON?) -> Object),
                toJSON: @escaping ((Object) -> JSON?),
                file: String = #file,
                line: Int = #line,
                column: Int = #column)
    {
        self.fromJSON = fromJSON
        self.toJSON = toJSON

        var hasher = Hasher()
        hasher.combine(String(describing: Object.self))
        hasher.combine(file)
        hasher.combine(line)
        hasher.combine(column)
        hash = hasher.finalize()
    }

    open func transformFromJSON(_ json: JSON?) -> Object {
        fromJSON(json)
    }

    open func transformToJSON(_ object: Object) -> JSON? {
        toJSON(object)
    }

    open func hashValue() -> Int {
        return hash
    }
}
