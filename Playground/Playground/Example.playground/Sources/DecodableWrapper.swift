//
//  JSONDecoder.swift
//  CodableDemo
//
//  Created by xubin on 2021/6/17.
//

import Foundation

///
/// 原生 JSONDecoder 的封装,  提高 Codable 模型的易用性
/// 1. 默认开启下划线转驼峰
/// 2. 默认输出解析失败描述, 忽略 try
/// 3. 支持 [String: Any], [Any], String, Data, Any
///
private class JSONDecoder: Foundation.JSONDecoder {
    fileprivate func decode<T>(_: T.Type, from json: String) throws -> T where T: Decodable {
        let data = json.data(using: .utf8)!
        return try decode(T.self, from: data)
    }

    fileprivate func decode<T>(_: T.Type, from dic: [String: Any]) throws -> T where T: Decodable {
        let data = try JSONSerialization.data(withJSONObject: dic, options: .fragmentsAllowed)
        return try decode(T.self, from: data)
    }

    fileprivate func decode<T>(_: T.Type, from array: [Any]) throws -> T where T: Decodable {
        let data = try JSONSerialization.data(withJSONObject: array, options: .fragmentsAllowed)
        return try decode(T.self, from: data)
    }
}

///
/// ```
/// Entity.decode(from: json)
/// [Entity].decode(from: json)
///
public extension Decodable {
    static func decode(from value: Any) throws -> Self {
        let decoder = JSONDecoder()
        if let json = value as? String {
            return try decoder.decode(Self.self, from: json)
        } else if let data = value as? Data {
            return try decoder.decode(Self.self, from: data)
        } else if let dic = value as? [String: Any] {
            return try decoder.decode(Self.self, from: dic)
        } else if let array = value as? [Any] {
            return try decoder.decode(Self.self, from: array)
        } else {
            throw NSError(domain: "undetected value: \(value)", code: 0, userInfo: nil)
        }
    }
}
