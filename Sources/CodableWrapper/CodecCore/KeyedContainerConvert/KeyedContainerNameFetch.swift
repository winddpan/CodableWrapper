//
//  KeyedContainerNameFetch.swift
//  CodableWrapper
//
//  Created by PAN on 2022/1/14.
//

import Foundation

extension KeyedDecodingContainer {
    // _TtGCs26_KeyedDecodingContainerBoxGVV14CodableWrapperP10$1026273fc15JSONDecoderImpl14KeyedContainer_VS0_12AnyCodingKey__$
    // _TtGCs26_KeyedDecodingContainerBoxGVV14CodableWrapperP10$1026273fc15JSONDecoderImpl14KeyedContainer_OV18CodableWrapperTest12ExampleModelP10$10240b1d810CodingKeys__$
    var boxIdentifier: String {
        let boxPtr = withUnsafePointer(to: self) { UnsafeRawPointer($0) }.load(as: UnsafeRawPointer.self)
        let containerBase = boxPtr.load(as: AnyObject.self)
        let clssName = "\(type(of: containerBase))".components(separatedBy: "_").prefix(3).joined(separator: "_")
        return clssName
    }
}

extension KeyedEncodingContainer {
    // _TtGCs26_KeyedEncodingContainerBoxGV14CodableWrapperP10$1074c620826JSONKeyedEncodingContainerVS0_12AnyCodingKey__$
    // _TtGCs26_KeyedEncodingContainerBoxGV14CodableWrapperP10$106cc620826JSONKeyedEncodingContainerOV18CodableWrapperTest12ExampleModelP10$101cc861810CodingKeys__$
    var boxIdentifier: String {
        let boxPtr = withUnsafePointer(to: self) { UnsafeRawPointer($0) }.load(as: UnsafeRawPointer.self)
        let containerBase = boxPtr.load(as: AnyObject.self)
        let clssName = "\(type(of: containerBase))".components(separatedBy: "_").prefix(3).joined(separator: "_")
        return clssName
    }
}
