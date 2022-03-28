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

    private let locker = NSLock()
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
        locker.lock(); defer { locker.unlock() }
        let name = container.boxIdentifier
        if decoderMap[name] == nil {
            decoderMap[name] = KeyedDecodingContainerModifier(refer: &container)
        }
    }

    private func registerEncodingContainer(_ container: inout KeyedEncodingContainer<AnyCodingKey>) {
        locker.lock(); defer { locker.unlock() }
        let name = container.boxIdentifier
        if encoderMap[name] == nil {
            encoderMap[name] = KeyedEncodingContainerModifier(refer: &container)
        }
    }

    func encodingContainerModifier<K>(for container: KeyedEncodingContainer<K>) -> KeyedEncodingContainerModifier? {
        locker.lock(); defer { locker.unlock() }
        if encoderMap.count == 1, let first = encoderMap.first {
            return first.value
        }
        return encoderMap[container.boxIdentifier]
    }

    func decodingContainerModifier<K>(for container: KeyedDecodingContainer<K>) -> KeyedDecodingContainerModifier? {
        locker.lock(); defer { locker.unlock() }
        if decoderMap.count == 1, let first = decoderMap.first {
            return first.value
        }
        return decoderMap[container.boxIdentifier]
    }
}
