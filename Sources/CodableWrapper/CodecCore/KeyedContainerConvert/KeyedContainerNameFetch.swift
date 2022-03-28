//
//  KeyedContainerNameFetch.swift
//  CodableWrapper
//
//  Created by PAN on 2022/1/14.
//

import Foundation

extension KeyedDecodingContainer {
    var boxIdentifier: String {
        let boxPtr = withUnsafePointer(to: self) { UnsafeRawPointer($0) }.load(as: UnsafeRawPointer.self)
        let boxMetadataPtr = boxPtr.load(as: UnsafeMutableRawPointer.self).assumingMemoryBound(to: ClassMetadataLayout.self)
        let boxMetadata = ClassMetadata(pointer: boxMetadataPtr)
        
        if let genericArg = boxMetadata.genericArguments().first, let genericMetadata = try? metadata(of: genericArg) {
            if var metadata = genericMetadata as? StructMetadata {
                return metadata.mangledName()
            } else if var metadata = genericMetadata as? ClassMetadata {
                return metadata.mangledName()
            } else if var metadata = genericMetadata as? EnumMetadata {
                return metadata.mangledName()
            }
        }
        fatalError("unknow KeyedDecodingContainer type: \(self)")
    }
}

extension KeyedEncodingContainer {
    var boxIdentifier: String {
        let boxPtr = withUnsafePointer(to: self) { UnsafeRawPointer($0) }.load(as: UnsafeRawPointer.self)
        let boxMetadataPtr = boxPtr.load(as: UnsafeMutableRawPointer.self).assumingMemoryBound(to: ClassMetadataLayout.self)
        let boxMetadata = ClassMetadata(pointer: boxMetadataPtr)
        
        if let genericArg = boxMetadata.genericArguments().first, let genericMetadata = try? metadata(of: genericArg) {
            if var metadata = genericMetadata as? StructMetadata {
                return metadata.mangledName()
            } else if var metadata = genericMetadata as? ClassMetadata {
                return metadata.mangledName()
            } else if var metadata = genericMetadata as? EnumMetadata {
                return metadata.mangledName()
            }
        }
        fatalError("unknow KeyedEncodingContainer type: \(self)")
    }
}
