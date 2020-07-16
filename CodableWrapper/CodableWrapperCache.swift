//
//  CodableWrapperCache.swift
//  CodableWrapper
//
//  Created by PAN on 2020/7/16.
//  Copyright © 2020 YR. All rights reserved.
//

import Foundation

class CodableWrapperCache {
    static let shared = CodableWrapperCache()
    private var cache: [String: Any] = [:]

    func cacheCodableWrapperConstruct<T: Codable>(_ construct: CodableWrapper<T>.Construct, propertyKey: String) {
        let key = "\(String(describing: T.self))_\(propertyKey)"
        cache[key] = construct
    }

    func getCodableWrapperConstruct<T: Codable>(type: T.Type, propertyKey: String) -> CodableWrapper<T>.Construct? {
        let key = "\(String(describing: T.self))_\(propertyKey)"
        return cache[key] as? CodableWrapper<T>.Construct
    }

    func clearCodableWrapperConstruct<T: Codable>(type: T.Type, propertyKey: String) {
        let key = "\(String(describing: T.self))_\(propertyKey)"
        cache[key] = nil
    }
}
