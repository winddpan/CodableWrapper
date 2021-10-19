//: [Previous](@previous)           [Homepage](Homepage)
import CodableWrapper
import Foundation
/*:
 # 支持自定义的属性转换
 > 当接口返回的数据总是需要在端上做相同的处理后才能继续使用时, 就可以将其处理过程抽离为 Transformer
 >
 > 支持自定义 Transformer, 遵循 `TransformType` 协议即可, 详见 TransformType.swift
 ---
 */
let json = #" { "registerTime": 1599238402 } "#
//: ## Native Codable
struct User: Codable {
    private let registerTime: Double
    var registerDate: Date {
        Date(timeIntervalSince1970: registerTime)
    }
}

example("Native: 保存时间戳, 并将手动转换后的 Date 暴露给外部使用") {
    let user = try User.decode(from: json)
    print("register Date:", user.registerDate)
}

/*:
 ## Codec
 */

struct CodecUser: Codable {
    @Codec(transformer: SecondDateTransform())
    var registerTime: Date?
}

example("Codec: 自动将返回的时间戳转换为 Date") {
    let user = try User.decode(from: json)
    print("register Date:", user.registerDate)
}

//: [Next](@next)
