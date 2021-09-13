/*:
> Tips:
 + 使用 `individualExampleEnabled` 来控制单次运行的实例数量
 + 为了更简洁的表达实例, 对 Decodable 进行了封装, 详见 Sources/DecodableWrapper.swift
 ## 背景
> Codable 在 Swift 4 推出, 用于解决手动解析带来的效率问题. 虽然目前已有其他的开源方案可以用于 JSON 解析, 但是对于已经使用了 Codable, 但是却同时备受其扰的项目而言, 还是希望能在不替换新方案的情况下, 解决 Codable 使用中遇到的问题
 ---
 
 ## Codable 目前存在的问题
 1. [默认值问题](DefaultValue)
 2. [字段缺失问题](KeyAbsence)
 3. [类型兼容问题](TypeConvertible)
 4. [枚举构造问题](EnumDecoding)
---
 
 ## 扩展功能
 + [多个 Key map 到同一个属性](MultiKeyMap)
 + [Transform](Transform)
 ---
 */
/*
 ## 核心原理
 + [如何绕过构造函数传递默认值](Core)
 + [如何插入自定义解析](Core)
 + [如何挂载附加功能](Core)
 */
//: [Next](@next)
