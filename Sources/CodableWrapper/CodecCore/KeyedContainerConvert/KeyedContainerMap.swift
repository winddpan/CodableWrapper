//
//  CoderMap.swift
//  CodableWrapper
//
//  Created by PAN on 2022/1/14.
//

import Foundation

public func CodableWrapperRegisterAdditionalCoder(decode: (Data) throws -> CodablePrepartion,
                                                  encode: (CodablePrepartion) throws -> Data)
{
    KeyedContainerMap.shared.registerCoder(decode: decode, encode: encode)
}

class KeyedContainerMap {
    static let shared = KeyedContainerMap()

    private var decoderMap: [String: KeyedDecodingContainerModifier] = [:]
    private var encoderMap: [String: KeyedEncodingContainerModifier] = [:]

    init() {
        registerCoder(
            decode: {
                try JSONDecoder().decode(CodablePrepartion.self, from: $0)
            }, encode: {
                try JSONEncoder().encode($0)
            }
        )
    }

    func registerCoder(decode: (Data) throws -> CodablePrepartion,
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
        let name = container.boxIdentifier
        if decoderMap[name] == nil {
            decoderMap[name] = KeyedDecodingContainerModifier(refer: &container)
        }
    }

    private func registerEncodingContainer(_ container: inout KeyedEncodingContainer<AnyCodingKey>) {
        let name = container.boxIdentifier
        if encoderMap[name] == nil {
            encoderMap[name] = KeyedEncodingContainerModifier(refer: &container)
        }
    }

    func encodingContainerModifier(forName name: String) -> KeyedEncodingContainerModifier? {
        return encoderMap[name]
    }

    func decodingContainerModifier(forName name: String) -> KeyedDecodingContainerModifier? {
        return decoderMap[name]
    }
}
