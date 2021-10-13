//
//  JSONDecoder.swift
//  CodableDemo
//
//  Created by xubin on 2021/6/17.
//

import Foundation

public struct GlobalConfig {
    public static var DefaultKeyDecodingStrategy = Foundation.JSONDecoder.KeyDecodingStrategy.useDefaultKeys
}

///
/// 原生 JSONDecoder 的封装,  提高 Codable 模型的易用性
/// 1. 默认开启下划线转驼峰
/// 2. 默认输出解析失败描述, 忽略 try
/// 3. 支持 [String: Any], [Any], String, Data, Any
///
private class JSONDecoder: Foundation.JSONDecoder {
    
    fileprivate func decode<T>(_: T.Type, from json: String) -> T? where T : Decodable {
        guard let data = json.data(using: .utf8) else { return nil }
        return decode(T.self, from: data)
    }
    
    fileprivate func decode<T>(_: T.Type, from dic: [String: Any]) -> T? where T : Decodable {
        guard let data = try? JSONSerialization.data(withJSONObject: dic, options: .fragmentsAllowed) else { return nil }
        return decode(T.self, from: data)
    }
    
    fileprivate func decode<T>(_: T.Type, from array: [Any]) -> T? where T : Decodable {
        guard let data = try? JSONSerialization.data(withJSONObject: array, options: .fragmentsAllowed) else { return nil }
        return decode(T.self, from: data)
    }
    
    fileprivate func decode<T>(_: T.Type, from data: Data) -> T? where T : Decodable {
        do {
            return try super.decode(T.self, from: data)
        } catch let error {
            print("❌ " + String(describing: T.self) + " parse failed: " + error.localizedDescription)
            switch error {
            case let DecodingError.dataCorrupted(context):
                print(context.debugDescription)
            case let DecodingError.keyNotFound(_, context):
                print(context.debugDescription)
            case let DecodingError.valueNotFound(_, context):
                print(context.debugDescription)
            case let DecodingError.typeMismatch(_, context):
                print(context.debugDescription)
            default:
               break
            }
            return nil
        }
    }
}

///
/// ```
/// Entity.decode(from: json)
/// [Entity].decode(from: json)
///
public extension Decodable {
    typealias KeyDecodingStrategy = Foundation.JSONDecoder.KeyDecodingStrategy

    static func decode(from value: Any?, strategy: KeyDecodingStrategy = GlobalConfig.DefaultKeyDecodingStrategy) -> Self? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = strategy
        
        if let json = value as? String {
            return decoder.decode(Self.self, from: json)
        } else if let data = value as? Data {
            return decoder.decode(Self.self, from: data)
        } else if let dic = value as? [String: Any] {
            return decoder.decode(Self.self, from: dic)
        } else if let array = value as? [Any] {
            return decoder.decode(Self.self, from: array)
        } else {
            return nil
        }
    }
}
