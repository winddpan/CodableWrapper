//
//  LosslessCodable.swift
//  CodableWrapper
//
//  Created by PAN on 2021/10/27.
//

import Foundation

public typealias LosslessCodable = LosslessEncodable & LosslessDecodable

public protocol LosslessEncodable: Encodable & AnyObject {}

public protocol LosslessDecodable: Decodable & AnyObject {
    init()
}
