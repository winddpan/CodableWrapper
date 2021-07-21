//
//  CodableWrapperDebug.swift
//  CodableWrapper
//
//  Created by xubin on 2021/7/21.
//

import Foundation

extension Codec: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        "\(wrappedValue)"
    }

    public var debugDescription: String {
        "\(wrappedValue)"
    }
}
