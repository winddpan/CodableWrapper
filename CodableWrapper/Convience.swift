//
//  CodableWrapperConvience.swift
//  CodableWrapperDev
//
//  Created by winddpan on 2020/8/15.
//  Copyright © 2020 YR. All rights reserved.
//

import Foundation

extension CodableWrapper {
    public convenience init(codingKeys: [String] = [], defaultValue: Value) {
        let construct = Construct(codingKeys: codingKeys, defaultValue: defaultValue)
        self.init(construct: construct)
    }
}

extension TransformWrapper {
    public convenience init<T: TransformType>(codingKeys: [String] = [], transformer: T) where T.Object == Value {
        let construct = Construct(codingKeys: codingKeys, fromNil: transformer.fromNil, fromJSON: transformer.fromJSON, toJSON: transformer.toJSON)
        self.init(construct: construct)
    }

    public convenience init<JSON: Codable>(codingKeys: [String] = [], fromNil: @escaping () -> Value, fromJSON: ((JSON) -> Value?)? = nil, toJSON: ((Value) -> JSON?)? = nil) {
        let construct = Construct(codingKeys: codingKeys,
                                  fromNil: fromNil,
                                  fromJSON: {
                                      if let json = $0 as? JSON {
                                          return fromJSON?(json)
                                      }
                                      return nil
                                  }, toJSON: {
                                      toJSON?($0)
                                  })
        self.init(construct: construct)
    }
}
