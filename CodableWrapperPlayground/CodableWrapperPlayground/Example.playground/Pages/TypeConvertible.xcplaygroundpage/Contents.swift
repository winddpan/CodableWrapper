//: [Previous](@previous)           [Homepage](Homepage)
import CodableWrapper
/*:
 # 类型兼容问题
 > 在前后端协作的时候, 经常出现字段基础类型不匹配的情况, 而 Codable 对于类型匹配极其严格, 一旦单个属性不匹配将会导致整个解析失败
 >
 > Codec 对基础类型进行了互相兼容, 如 Bool 支持 0/1/'0'/'true'..., 详情参考 HandyJSON/BuiltInBridgeType.Swift
 ---
 */
let json = #"""
    {
        "name": "scyano",
        "vip": 0
    }
"""#
//: ## Native Codable
struct User: Codable {
    let vip: Bool
    let name: String
}

example("native.1: 返回的类型和属性类型不匹配, 解析失败❌") {
    if let user = User.decode(from: json) {
        print(user)
    }
}
//: `Compatible Solution`
struct BoolConvertible: Codable, Equatable, ExpressibleByBooleanLiteral, CustomStringConvertible {
    private var value: Bool = false
    
    var description: String {
        "\(value)"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        }
        if let intValue = try? container.decode(Int.self) {
            value = intValue != 0
        }
//        if let stringValue = try? container.decode(String.self) {...}
    }
    
    init(booleanLiteral value: Bool) {
        self.value = value
    }
    
    public static func == (lhs: BoolConvertible, rhs: Bool) -> Bool {
        return lhs.value == rhs
    }
}

struct ConvertibleUser: Codable {
    var vip: BoolConvertible = true
    let name: String
}

example("native.2: 封装一个新类型用于防止解析失败, 需要额外实现一些原本类型的行为") {
    if let user = ConvertibleUser.decode(from: json) {
        print(user)
        // if user.vip == true {...}
    }
}
/*:
 ## Codec
 */
struct CodecUser: Codable {
    @Codec var vip: Bool = true
    @Codec var name: String = "scyano"
}

example("Codec.1: 非/0 将兼容 Bool, 解析成功✅") {
    if let user = CodecUser.decode(from: json) {
        print(user)
    }
}
//: [Next](@next)
