//
//  ContainerTransformer.swift
//  CodableWrapper
//
//  Created by PAN on 2021/12/14.
//

import Foundation

class ContainerTransformer<T: CodingKey> {
    private let metadata: Int
    private let containerPtr: UnsafeRawPointer
    private let boxPtr: UnsafeMutableRawPointer

    init(decode: inout KeyedDecodingContainer<T>) {
        containerPtr = withUnsafePointer(to: &decode) { UnsafeRawPointer($0) }
        boxPtr = containerPtr.load(as: UnsafeMutableRawPointer.self)
        metadata = boxPtr.load(as: Int.self)
    }

    init(encode: inout KeyedEncodingContainer<T>) {
        containerPtr = withUnsafePointer(to: &encode) { UnsafeRawPointer($0) }
        boxPtr = containerPtr.load(as: UnsafeMutableRawPointer.self)
        metadata = boxPtr.load(as: Int.self)
    }

    // Decode
    func convertDecodingContainer() -> KeyedDecodingContainer<AnyCodingKey> {
        if ContainerMetadataBytes.shared.isBoxClass {
            boxPtr.storeBytes(of: ContainerMetadataBytes.shared.decodeMetadata, as: Int.self)
        }
        return containerPtr.load(as: KeyedDecodingContainer<AnyCodingKey>.self)
    }

    func convertBackDecodingContainer() {
        if ContainerMetadataBytes.shared.isBoxClass {
            boxPtr.storeBytes(of: metadata, as: Int.self)
        }
    }

    // Encode
    func convertEncodingContainer() -> KeyedEncodingContainer<AnyCodingKey> {
        if ContainerMetadataBytes.shared.isBoxClass {
            boxPtr.storeBytes(of: ContainerMetadataBytes.shared.encodeMetadata, as: Int.self)
        }
        return containerPtr.load(as: KeyedEncodingContainer<AnyCodingKey>.self)
    }

    func convertBackEncodingContainer() {
        if ContainerMetadataBytes.shared.isBoxClass {
            boxPtr.storeBytes(of: metadata, as: Int.self)
        }
    }
}

class ContainerMetadataBytes {
    let decodeMetadata: Int
    let encodeMetadata: Int
    let isBoxClass: Bool

    static let shared: ContainerMetadataBytes = {
        let data = #"{"decodeContainerMetadata": 1}"#.data(using: .utf8)!
        let tester = try! JSONDecoder().decode(ContainerMetadataTester.self, from: data)
        _ = try! JSONEncoder().encode(tester)
        return ContainerMetadataBytes(decode: tester.decodeMetadata, encode: tester.encodeMetadata, isBoxClass: tester.isBoxClass)
    }()

    required init(decode: Int, encode: Int, isBoxClass: Bool) {
        decodeMetadata = decode
        encodeMetadata = encode
        self.isBoxClass = isBoxClass
    }
}

private class ContainerMetadataTester: Codable {
    let decodeMetadata: Int
    var encodeMetadata: Int = 0
    let isBoxClass: Bool

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
