//
//  UnsafePropertyFetcher.swift
//  CodableWrapper
//
//  Created by xubin on 2021/7/20.
//

import Foundation

/*
 KeyedDecodingContainer `struct` - -
 | _box: _KeyedDecodingContainerBox `class` - -
 | | concrete: _JSONKeyedDecodingContainer `struct` - -
 | | | decoder: Foundation.__JSONDecoder `class` - -
 | | | container: Dictionary<String: Any> `struct` - -
 | | |
 */
extension KeyedDecodingContainer {
    func _decoder() -> Decoder {
        let boxPtr = withUnsafePointer(to: self) { UnsafeRawPointer($0) }.load(as: UnsafeRawPointer.self)
        let decoder = boxPtr.advanced(by: MemoryLayout<Int>.stride * 2).load(as: AnyObject.self)
        return decoder as! Decoder
    }

    func _containerDictionary() -> [String: Any] {
        let boxPtr = withUnsafePointer(to: self) { UnsafeRawPointer($0) }.load(as: UnsafeRawPointer.self)
        let container = boxPtr.advanced(by: MemoryLayout<Int>.stride * 3).load(as: [String: Any].self)
        return container
    }
}

/*
 KeyedEncodingContainer `struct`
 | _box: _KeyedEncodingContainerBase `class` - -
 | | concrete:  _JSONKeyedEncodingContainer `struct` - -
 | | | encoder: Foundation.__JSONEncoder `class` - -
 | | | container: NSMutableDictionary `class` - -
 | | |
 */
extension KeyedEncodingContainer {
    func _encoder() -> Encoder {
        let boxPtr = withUnsafePointer(to: self) { UnsafeRawPointer($0) }.load(as: UnsafeRawPointer.self)
        let endcoder = boxPtr.advanced(by: MemoryLayout<Int>.stride * 2).load(as: AnyObject.self)
        return endcoder as! Encoder
    }

    func _container() -> NSMutableDictionary {
        let boxPtr = withUnsafePointer(to: self) { UnsafeRawPointer($0) }.load(as: UnsafeRawPointer.self)
        let container = boxPtr.advanced(by: MemoryLayout<Int>.stride * 3).load(as: NSMutableDictionary.self)
        return container
    }
}
