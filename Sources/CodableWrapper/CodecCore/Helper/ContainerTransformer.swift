//
//  ContainerTransformer.swift
//  CodableWrapper
//
//  Created by PAN on 2021/12/14.
//

import Foundation

extension KeyedDecodingContainer {
    mutating func convertAsAnyCodingKey(_ handler: (inout KeyedDecodingContainer<AnyCodingKey>) throws -> Void) throws
    {
        let transformer = ContainerTransformer(container: &self)
        var transformed = transformer.convertDecodingContainer()
        try handler(&transformed)
        transformer.convertBackDecodingContainer()
    }
}

extension KeyedEncodingContainer {
    mutating func convertAsAnyCodingKey(_ handler: (inout KeyedEncodingContainer<AnyCodingKey>) throws -> Void) throws
    {
        let transformer = ContainerTransformer(container: &self)
        var transformed = transformer.convertEncodingContainer()
        try handler(&transformed)
        transformer.convertBackEncodingContainer()
    }
}

private struct ContainerTransformer<T: CodingKey> {
    private let metadata: Int
    private let containerPtr: UnsafeRawPointer
    private let boxPtr: UnsafeMutableRawPointer

    init(container: inout KeyedDecodingContainer<T>) {
        containerPtr = withUnsafePointer(to: &container) { UnsafeRawPointer($0) }
        boxPtr = containerPtr.load(as: UnsafeMutableRawPointer.self)
        metadata = boxPtr.load(as: Int.self)
    }

    init(container: inout KeyedEncodingContainer<T>) {
        containerPtr = withUnsafePointer(to: &container) { UnsafeRawPointer($0) }
        boxPtr = containerPtr.load(as: UnsafeMutableRawPointer.self)
        metadata = boxPtr.load(as: Int.self)
    }

    // Decode
    func convertDecodingContainer() -> KeyedDecodingContainer<AnyCodingKey> {
        if ContainerMetadataBytes.info.isBoxClass {
            boxPtr.storeBytes(of: ContainerMetadataBytes.info.decodeMetadata, as: Int.self)
        }
        return containerPtr.load(as: KeyedDecodingContainer<AnyCodingKey>.self)
    }

    func convertBackDecodingContainer() {
        if ContainerMetadataBytes.info.isBoxClass {
            boxPtr.storeBytes(of: metadata, as: Int.self)
        }
    }

    // Encode
    func convertEncodingContainer() -> KeyedEncodingContainer<AnyCodingKey> {
        if ContainerMetadataBytes.info.isBoxClass {
            boxPtr.storeBytes(of: ContainerMetadataBytes.info.encodeMetadata, as: Int.self)
        }
        return containerPtr.load(as: KeyedEncodingContainer<AnyCodingKey>.self)
    }

    func convertBackEncodingContainer() {
        if ContainerMetadataBytes.info.isBoxClass {
            boxPtr.storeBytes(of: metadata, as: Int.self)
        }
    }
}

private struct ContainerMetadataBytes {
    let decodeMetadata: Int
    let encodeMetadata: Int
    let isBoxClass: Bool

    static let info: ContainerMetadataBytes = {
        let data = #"{"decodeContainerMetadata": 1}"#.data(using: .utf8)!
        let tester = try! JSONDecoder().decode(ContainerMetadataTester.self, from: data)
        _ = try! JSONEncoder().encode(tester)
        return ContainerMetadataBytes(decodeMetadata: tester.decodeMetadata,
                                      encodeMetadata: tester.encodeMetadata,
                                      isBoxClass: tester.isBoxClass)
    }()

    class ContainerMetadataTester: Codable {
        let decodeMetadata: Int
        var encodeMetadata: Int = 0
        var isBoxClass: Bool = false

        required init(from decoder: Decoder) throws {
            var container = try decoder.container(keyedBy: AnyCodingKey.self)
            let ptr = withUnsafePointer(to: &container) { UnsafeRawPointer($0) }.load(as: UnsafeRawPointer.self)
            decodeMetadata = ptr.load(as: Int.self)

            let mirror = Mirror(reflecting: container)
            if let firstChild = mirror.children.first?.value, Mirror(reflecting: firstChild).displayStyle == .class {
                isBoxClass = true
            } else {
                isBoxClass = false
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: AnyCodingKey.self)
            let ptr = withUnsafePointer(to: &container) { UnsafeRawPointer($0) }.load(as: UnsafeRawPointer.self)
            encodeMetadata = ptr.load(as: Int.self)
        }
    }
}
