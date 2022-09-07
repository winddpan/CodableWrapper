//
//  CoderMap.swift
//  CodableWrapper
//
//  Created by PAN on 2022/1/14.
//

import Foundation

class KeyedContainerMap {
    static let shared = KeyedContainerMap()

    private var decoderModifier: KeyedDecodingContainerModifier?
    private var encoderModifier: KeyedEncodingContainerModifier?

    init() {
        registerCoder(
            decode: {
                try JSONDecoder().decode(CodablePrepartion.self, from: $0)
            }, encode: {
                try JSONEncoder().encode($0)
            }
        )
    }

    private func registerCoder(decode: (Data) throws -> CodablePrepartion,
                               encode: (CodablePrepartion) throws -> Data)
    {
        let data = #"{}"#.data(using: .utf8)!
        do {
            let prepartion = try decode(data)
            registerDecodingContainer(&prepartion.keyedDecodingContainer)
            _ = try encode(prepartion)
            registerEncodingContainer(&prepartion.keyedEncodingContainer!)
        } catch {}
    }

    private func registerDecodingContainer(_ container: inout KeyedDecodingContainer<AnyCodingKey>) {
        decoderModifier = KeyedDecodingContainerModifier(refer: &container)
    }

    private func registerEncodingContainer(_ container: inout KeyedEncodingContainer<AnyCodingKey>) {
        encoderModifier = KeyedEncodingContainerModifier(refer: &container)
    }

    func encodingContainerModifier<K>(for container: KeyedEncodingContainer<K>) -> KeyedEncodingContainerModifier? {
        encoderModifier
    }

    func decodingContainerModifier<K>(for container: KeyedDecodingContainer<K>) -> KeyedDecodingContainerModifier? {
        decoderModifier
    }
}
