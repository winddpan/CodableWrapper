//: [Previous](@previous)           [Homepage](Homepage)
import CodableWrapper
/*:
 # 支持多个 Key 映射到同一个属性
 > 业务迭代中, 功能有交集的多个接口可能会复用同一个数据模型. 由于种种原因, 不同接口中相同字段使用了不同的 key, 端上只能兼容多个 key
 ---
 */
//: ## Native Codable
struct User: Codable {
    var vip: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case vip = "vip_user"
    }
}

example("Native.1: 另一个接口返回类似模型, key 不同, 无法解析❌") {
    let api1 = #" { "vip_user": true } "#
    let api2 = #" { "is_vip": true } "#
    
    if let user1 = User.decode(from: api1) {
        print("user1: ", user1)
    }
    if let user2 = User.decode(from: api2) {
        print("user2: ", user2)
    }
}
/*:
 ## Codec
 */
struct CodecUser: Codable {
    @Codec("is_vip", "vip_user")
    var vip: Bool = false
}

example("Codec.1: 多个 key 可同时映射到一个属性, 解析成功✅") {
    let api1 = #" { "vip":true } "#
    let api2 = #" { "is_vip":true } "#
    let api3 = #" { "vip_user":true } "#
    
    [api1, api2, api3]
        .compactMap { CodecUser.decode(from: $0) }
        .enumerated()
        .forEach { print("user\($0+1): \($1)") }
}
//: `Support DecodingKeyStrategy`
struct CodecAutoConvertUser: Codable {
    @Codec("vip_user", "user_vip")
    var isVip: Bool = false
}

example("Codec.2: 使用驼峰转下划线✅") {
    let api1 = #" { "is_vip":true } "#
    let api2 = #" { "vip_user":true } "#
    let api3 = #" { "user_vip":true } "#
    
    [api1, api2, api3]
        .compactMap { CodecUser.decode(from: $0, strategy: .convertFromSnakeCase) }
        .enumerated()
        .forEach { print("user\($0+1): \($1)") }
}
//: [Next](@next)

