//
//  HasherChain.swift
//  CodableWrapperTest
//
//  Created by PAN on 2021/8/3.
//

import Foundation

class HasherChain {
    private var hasher = Hasher()

    func combine<H: Hashable>(_ value: H) -> HasherChain {
        hasher.combine(value)
        return self
    }

    var hashValue: Int {
        hasher.finalize()
    }
}
