//: [Previous](@previous)           [Homepage](Homepage)
import CodableWrapper
/*:
 # 枚举类型解析问题
 > 在业务迭代中, 为已有的枚举类型新增 case 是很常见的场景. 但 Codable 在解析到不匹配枚举的 rawValue 时, 会导致整个解析失败
 ---
 */
individualExampleEnabled = true

let json = #"""
    {
        "name": "scyano",
        "vip": 99
    }
"""#
//: ## 原生 Codable
enum UserVipLevel: Int, Codable {
    case none = 0
    case month = 1
    case year = 2
}

struct User: Codable {
    let vip: UserVipLevel
    let name: String
}

example("Native.1: enum 返回不支持的 rawValue, 解析失败❌") {
    let user = try User.decode(from: json)
    print(user)
}

//: `Compatible Solution`
struct OptionalUser: Codable {
    private var vip: Int?
    let name: String
    var userVipLevel: UserVipLevel {
        UserVipLevel(rawValue: vip ?? 0) ?? .none
    }
}

example("Native.2: 使用 RawValue.Type 来承接值, 并手动对外返回 case, 防止解析失败😅") {
    let user = try OptionalUser.decode(from: json)
    print("name: \(user.name), vip: \(user.userVipLevel)")
}

/*:
 ## Codec
 */
struct CodecUser: Codable {
    @Codec var vip: UserVipLevel = .none
    @Codec var name: String = "scyano"
}

example("Codec.1: rawValue 不匹配, 枚举解析失败, 使用默认 case✅") {
    let user = try CodecUser.decode(from: json)
    print(user)
}

//: [Next](@next)
