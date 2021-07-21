//
//  CodableWrapperInit.swift
//  CodableWrapper
//
//  Created by winddpan on 2020/8/15.
//

import Foundation

public extension CodableWrapper where Value: Codable {
    convenience init(codingKeys: [String] = [], defaultValue: Value) {
        self.init(unsafed: ())
        self.codingKeys = codingKeys
        self.wrappedValue = defaultValue
    }

    convenience init<Wrapped>(codingKeys: [String] = []) where Value == Wrapped? {
        self.init(unsafed: ())
        self.codingKeys = codingKeys
        self.wrappedValue = Wrapped?.none
    }
}
