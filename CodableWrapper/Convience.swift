//
//  CodableWrapperConvience.swift
//  CodableWrapperDev
//
//  Created by winddpan on 2020/8/15.
//  Copyright © 2020 YR. All rights reserved.
//

import Foundation

extension CodableWrapper {
    public convenience init<Wrapped>(codingKeys: [String] = []) where Value == Wrapped? {
        let construct = Construct(codingKeys: codingKeys, fromNull: { Optional<Wrapped>.none }, fromJSON: { _ in .default }, toJSON: { _ in .default })
        self.init(construct: construct)
    }

    public convenience init(codingKeys: [String] = [], defaultValue: Value) {
        let construct = Construct(codingKeys: codingKeys, fromNull: { defaultValue }, fromJSON: { _ in .default }, toJSON: { _ in .default })
        self.init(construct: construct)
    }

    public convenience init<T: TransformType>(codingKeys: [String] = [], transformer: T) where T.Object == Value {
        let construct = Construct(codingKeys: codingKeys, fromNull: transformer.fromNull, fromJSON: transformer.fromJSON, toJSON: transformer.toJSON)
        self.init(construct: construct)
    }
}
