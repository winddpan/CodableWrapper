//
//  CodableWrapperInit.swift
//  CodableWrapper
//
//  Created by winddpan on 2020/8/15.
//

import Foundation

public extension CodableWrapper where Value: Codable {
    convenience init(codingKeys: [String] = [], defaultValue: Value) {
        let construct = Construct(codingKeys: codingKeys, fromNull: { defaultValue }, fromJSON: { _ in .default }, toJSON: { _ in .default })
        self.init(construct: construct)
    }

    convenience init<Wrapped>(codingKeys: [String] = []) where Value == Wrapped? {
        let construct = Construct(codingKeys: codingKeys, fromNull: { Wrapped?.none }, fromJSON: { _ in .default }, toJSON: { _ in .default })
        self.init(construct: construct)
    }
}

public extension CodableWrapper {
    convenience init<T: TransformType>(codingKeys: [String] = [], transformer: T) where T.Object == Value {
        let construct = Construct(codingKeys: codingKeys, fromNull: transformer.fromNull, fromJSON: transformer.fromJSON, toJSON: transformer.toJSON)
        self.init(construct: construct)
    }
}
