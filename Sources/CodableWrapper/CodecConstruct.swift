//
//  CodecConstruct.swift
//  CodableWrapper
//
//  Created by PAN on 2021/8/3.
//

import Foundation

class CodecConstruct: Hashable {
    var codingKeys: [String] = []
    var transformer: AnyTransfromTypeTunk?

    init(codingKeys: [String], transformer: AnyTransfromTypeTunk? = nil) {
        self.codingKeys = codingKeys
        self.transformer = transformer
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(codingKeys)
        hasher.combine(transformer?.hashValue)
    }

    static func == (lhs: CodecConstruct, rhs: CodecConstruct) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
