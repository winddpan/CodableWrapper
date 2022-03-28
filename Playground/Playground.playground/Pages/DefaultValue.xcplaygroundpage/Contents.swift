//: [Previous](@previous)           [Homepage](Homepage)
import CodableWrapper
/*:
 # 默认值问题
 > 如果想在解析失败后使用我们设置的默认值, 是不可行的.
 >
 > 这里有两种情况: 1. 它被解析正确的值覆盖; 2. 它被解析失败的 nil 覆盖
 ---
 */
individualExampleEnabled = true

let json = #"""
    {
        "vip": true,
        "nicknames": [
            "Baymax",
            "Kitty"
        ]
    }
"""#
//: ## Native Codable
struct User: Codable {
    var vip: Bool = false
    var name: String? = "scyano"
    var nicknames: [String] = []
}

example("Native: vip & nicknames 的默认值被解析成功的值覆盖; name 解析失败, 默认值被 nil覆盖") {
    let user = try User.decode(from: json)
    print(user)
}

/*:
 ## Codec
 */
struct CodecUser: Codable {
    @Codec var vip: Bool = false
    @Codec var name: String = "scyano"
    @Codec var nicknames: [String] = []
}

example("Codec: vip & nicknames 的默认值被解析成功的值覆盖; name 解析失败, 使用默认值") {
    let user = try CodecUser.decode(from: json)
    print(user)
}

//: [Next](@next)
