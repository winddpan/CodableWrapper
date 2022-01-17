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

    for (i, api) in [api1, api2].enumerated() {
        do {
            let user = try User.decode(from: api)
            print("user\(i+1):", user)
        } catch {
            print("user\(i+1):", error)
        }
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

    for (i, api) in [api1, api2, api3].enumerated() {
        do {
            let user = try CodecUser.decode(from: api)
            print("user\(i+1):", user)
        } catch {
            print(error)
        }
    }
}

//: `Support DecodingKeyStrategy`
struct CodecAutoConvertUser: Codable {
    @Codec("vipUser", "user_vip")
    var isVip: Bool = false
}

example("Codec.2: 驼峰下划线自动转换✅") {
    let api1 = #" { "is_vip":true } "#
    let api2 = #" { "vip_user":true } "#
    let api3 = #" { "userVip":true } "#

    for (i, api) in [api1, api2, api3].enumerated() {
        do {
            let user = try CodecAutoConvertUser.decode(from: api)
            print("user\(i+1):", user)
        } catch {
            print(error)
        }
    }
}

//: [Next](@next)
