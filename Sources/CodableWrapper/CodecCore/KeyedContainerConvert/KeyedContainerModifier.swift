//
//  KeyedContainerModifier.swift
//  CodableWrapper
//
//  Created by PAN on 2022/1/14.
//

import Foundation

class KeyedDecodingContainerModifier {
    let referPtrStruct: ContainerPtrStruct
    let concreteIsClass: Bool

    required init(refer: inout KeyedDecodingContainer<AnyCodingKey>) {
        let referPointer = withUnsafePointer(to: &refer) { UnsafeRawPointer($0) }
        let box = referPointer.load(as: AnyObject.self)
        if let concrete = Mirror(reflecting: box).children.first?.value, Mirror(reflecting: concrete).displayStyle == .class {
            concreteIsClass = true
        } else {
            concreteIsClass = false
        }
        referPtrStruct = ContainerPtrStruct(containerPtr: referPointer, concreteIsClass: concreteIsClass)
    }

    func convert<K>(target: inout KeyedDecodingContainer<K>, handler: (inout KeyedDecodingContainer<AnyCodingKey>) throws -> Void) throws {
        let targetPointer = withUnsafePointer(to: &target) { UnsafeRawPointer($0) }
        let syncer = _KeyedContainerSyncer(refer: referPtrStruct, target: targetPointer, concreteIsClass: concreteIsClass)

        syncer.syncToRefer()
        var output = targetPointer.load(as: KeyedDecodingContainer<AnyCodingKey>.self)
        try handler(&output)
        syncer.revert()
    }
}

class KeyedEncodingContainerModifier {
    let referPtrStruct: ContainerPtrStruct
    let concreteIsClass: Bool

    required init(refer: inout KeyedEncodingContainer<AnyCodingKey>) {
        let referPointer = withUnsafePointer(to: &refer) { UnsafeRawPointer($0) }
        let box = referPointer.load(as: AnyObject.self)
        if let concrete = Mirror(reflecting: box).children.first?.value, Mirror(reflecting: concrete).displayStyle == .class {
            concreteIsClass = true
        } else {
            concreteIsClass = false
        }
        referPtrStruct = ContainerPtrStruct(containerPtr: referPointer, concreteIsClass: concreteIsClass)
    }

    func convert<K>(target: inout KeyedEncodingContainer<K>, handler: (inout KeyedEncodingContainer<AnyCodingKey>) throws -> Void) throws {
        let targetPointer = withUnsafePointer(to: &target) { UnsafeRawPointer($0) }
        let syncer = _KeyedContainerSyncer(refer: referPtrStruct, target: targetPointer, concreteIsClass: concreteIsClass)

        syncer.syncToRefer()
        var output = targetPointer.load(as: KeyedEncodingContainer<AnyCodingKey>.self)
        try handler(&output)
        syncer.revert()
    }
}

enum KeyedContainerConvertError: Error {
    case unregistered
    case convertFailure
}

class _KeyedContainerSyncer {
    private let refer: ContainerPtrStruct
    private let target: ContainerPtrStruct
    private let concreteIsClass: Bool

    required init(refer: ContainerPtrStruct, target: UnsafeRawPointer, concreteIsClass: Bool) {
        self.refer = refer
        self.target = ContainerPtrStruct(containerPtr: target, concreteIsClass: concreteIsClass)
        self.concreteIsClass = concreteIsClass
    }

    func syncToRefer() {
        if concreteIsClass {
            // write convrete metadata
            target.boxPtr.advanced(by: MemoryLayout<Int>.size * 2).load(as: UnsafeMutableRawPointer.self).storeBytes(of: refer.concreteMedata, as: Int.self)
        }
        // write box metadata
        target.boxPtr.storeBytes(of: refer.boxMetadata, as: Int.self)
    }

    func revert() {
        if concreteIsClass {
            // revert convrete metadata
            target.boxPtr.advanced(by: MemoryLayout<Int>.size * 2).load(as: UnsafeMutableRawPointer.self).storeBytes(of: target.concreteMedata, as: Int.self)
        }
        // revert box metadata
        target.boxPtr.storeBytes(of: target.boxMetadata, as: Int.self)
    }
}

struct ContainerPtrStruct {
    let boxPtr: UnsafeMutableRawPointer
    let boxMetadata: Int
    var concretePtr: UnsafeMutableRawPointer!
    var concreteMedata: Int!

    init(containerPtr: UnsafeRawPointer, concreteIsClass: Bool) {
        boxPtr = containerPtr.load(as: UnsafeMutableRawPointer.self)
        boxMetadata = boxPtr.load(as: Int.self)

        if concreteIsClass {
            concretePtr = boxPtr.advanced(by: MemoryLayout<Int>.size * 2).load(as: UnsafeMutableRawPointer.self)
            concreteMedata = concretePtr?.load(as: Int.self)
        }
    }
}
