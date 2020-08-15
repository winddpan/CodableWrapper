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
    public convenience init<T: TransformType>(codingKeys: [String] = [],
                                              transformer: T) where T.Object == Value {
        let construct = Construct(codingKeys: codingKeys, fromNil: transformer.fromNil, fromJSON: transformer.fromJSON, toJSON: transformer.toJSON)
        self.init(construct: construct)
    }

    public convenience init(codingKeys: [String] = [],
                            fromNil: @escaping () -> Value,
                            fromJSON: ((Any) -> Value?)? = nil,
                            toJSON: ((Value) -> Encodable?)? = nil) {
        
        let construct = Construct(codingKeys: codingKeys,
                                  fromNil: {
                                      fromNil()
                                  },
                                  fromJSON: {
                                      if let fromJSON = fromJSON {
                                          return TransformTypeResult<Value?>.result(fromJSON($0))
                                      }
                                      return TransformTypeResult<Value?>.unImplement
                                  },
                                  toJSON: {
                                      if let toJSON = toJSON {
                                          return TransformTypeResult<Encodable?>.result(toJSON($0))
                                      }
                                      return TransformTypeResult<Encodable?>.unImplement
                                  })
        self.init(construct: construct)
    }
}
