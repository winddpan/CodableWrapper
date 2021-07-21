//
//  AnyCodingKey.swift
//  CodableWrapper
//
//  Created by winddpan on 2020/8/15.
//

import Foundation

struct AnyCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int?

    init?(stringValue: String) {
        self.stringValue = stringValue
        intValue = nil
    }

    init?(intValue: Int) {
        stringValue = "\(intValue)"
        self.intValue = intValue
    }

    init(index: Int) {
        stringValue = "\(index)"
        intValue = index
    }
}
