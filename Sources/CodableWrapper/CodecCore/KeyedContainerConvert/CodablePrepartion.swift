//
//  CodablePrepartion.swift
//  CodableWrapper
//
//  Created by PAN on 2022/1/14.
//

import Foundation

final class CodablePrepartion: Codable {
    var keyedDecodingContainer: KeyedDecodingContainer<AnyCodingKey>
    var keyedEncodingContainer: KeyedEncodingContainer<AnyCodingKey>?

    public required init(from decoder: Decoder) throws {
        keyedDecodingContainer = try decoder.container(keyedBy: AnyCodingKey.self)
    }

    public func encode(to encoder: Encoder) throws {
        keyedEncodingContainer = encoder.container(keyedBy: AnyCodingKey.self)
    }
}
