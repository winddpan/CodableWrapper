//: [Previous](@previous)           [Homepage](Homepage)
import CodableWrapper
/*:
 # 字段缺失问题
 > 实际使用中往往会遇见 key 缺失的问题:
 >
 > 服务端去除无用字段, 服务端字段重命名等情况都会引起 Codable 解析失败
 ---
 */
let json = #"""
    {
        "name": "scyano"
    }
"""#
//: ## Native Codable
struct User: Codable {
    var vip: Bool = false
    var name: String = ""
}

example("Native.1: vip 字段缺失, 解析失敗❌") {
    let user = try User.decode(from: json)
    print(user)
}

//: `Compatible Solution`
struct OptionalUser: Codable {
    let vip: Bool?
    let name: String?
}

example("Native.2: 将所有属性声明为 Optional, 防止解析失败😅") {
    let user = try OptionalUser.decode(from: json)
    /* usage
      let vip = user.vip ?? false
      let name = user.name ?? ""
     */
    print(user)
}

/*:
 ## Codec
 */
struct CodecUser: Codable {
    @Codec var vip: Bool = false
    @Codec var name: String = "scyano"
}

example("Codec.1: 缺失的 Key 对应的属性, 会保持默认值") {
    let user = try CodecUser.decode(from: json)
    print(user)
}

//: [Next](@next)
