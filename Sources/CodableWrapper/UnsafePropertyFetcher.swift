//
//  UnsafePropertyFetcher.swift
//  CodableWrapper
//
//  Created by xubin on 2021/7/20.
//

import Foundation

/*
 KeyedDecodingContainer struct - -
 | _box: _KeyedDecodingContainerBox class - -
 | | concrete: KeyedDecodingContainer(KeyedDecodingContainerProtocol) protocol - -
 | | | decoder: Foundation.__JSONDecoder - -
 | | | container: Dictionary<String: Any> - -
 | | |
 */
extension KeyedDecodingContainer {
    
    func _decoder() -> Decoder? {
        let stackPointer = withUnsafePointer(to: self) { UnsafeRawPointer($0) }
        let box = stackPointer.load(as: UnsafeRawPointer.self)
        let concrete = box.load(fromByteOffset: 16, as: UnsafeMutableRawPointer.self)
        let metatype = concrete.load(as: Int.self)
        
        var refCount = concrete.load(fromByteOffset: 12, as: Int32.self)
        refCount += 2
        concrete.storeBytes(of: refCount, toByteOffset: 12, as: Int32.self)
        
        var decoder: Any = 0
        let decoderPointer = withUnsafePointer(to: &decoder) { UnsafeMutableRawPointer(mutating: $0) }
        decoderPointer.storeBytes(of: concrete, as: UnsafeRawPointer.self)
        decoderPointer.storeBytes(of: metatype, toByteOffset: 24, as: Int.self)
        
        return decoder as? Decoder
    }

    func _containerDictionary() -> [String: Any]? {
        let stackPointer = withUnsafePointer(to: self) { UnsafeRawPointer($0) }
        let box = stackPointer.load(as: UnsafeRawPointer.self)
        let concrete = box.load(fromByteOffset: 24, as: UnsafeMutableRawPointer.self)
        let metatype = concrete.load(as: Int.self)
        
        var refCount = concrete.load(fromByteOffset: 12, as: Int32.self)
        refCount += 2
        concrete.storeBytes(of: refCount, toByteOffset: 12, as: Int32.self)
        
        var container: Any = 0
        let containerPointer = withUnsafePointer(to: &container) { UnsafeMutableRawPointer(mutating: $0) }
        containerPointer.storeBytes(of: concrete, as: UnsafeRawPointer.self)
        containerPointer.storeBytes(of: metatype, toByteOffset: 24, as: Int.self)
        
        return container as? [String: Any]
    }
}

extension KeyedEncodingContainer {
    
    func _encoder() -> Encoder? {
        let stackPointer = withUnsafePointer(to: self) { UnsafeRawPointer($0) }
        let box = stackPointer.load(as: UnsafeRawPointer.self)
        let concrete = box.load(fromByteOffset: 16, as: UnsafeMutableRawPointer.self)
        let metatype = concrete.load(as: Int.self)
        
        var refCount = concrete.load(fromByteOffset: 12, as: Int32.self)
        refCount += 2
        concrete.storeBytes(of: refCount, toByteOffset: 12, as: Int32.self)
        
        var encoder: Any = 0
        let encoderPointer = withUnsafePointer(to: &encoder) { UnsafeMutableRawPointer(mutating: $0) }
        encoderPointer.storeBytes(of: concrete, as: UnsafeRawPointer.self)
        encoderPointer.storeBytes(of: metatype, toByteOffset: 24, as: Int.self)
        
        return encoder as? Encoder
    }

    func _container() -> NSMutableDictionary? {
        let stackPointer = withUnsafePointer(to: self) { UnsafeRawPointer($0) }
        let box = stackPointer.load(as: UnsafeRawPointer.self)
        let concrete = box.load(fromByteOffset: 24, as: UnsafeMutableRawPointer.self)
        let metatype = concrete.load(as: Int.self)
        
        var refCount = concrete.load(fromByteOffset: 12, as: Int32.self)
        refCount += 2
        concrete.storeBytes(of: refCount, toByteOffset: 12, as: Int32.self)
        
        var container: Any = 0
        let containerPointer = withUnsafePointer(to: &container) { UnsafeMutableRawPointer(mutating: $0) }
        containerPointer.storeBytes(of: concrete, as: UnsafeRawPointer.self)
        containerPointer.storeBytes(of: metatype, toByteOffset: 24, as: Int.self)
        
        return container as? NSMutableDictionary
    }
}
