# Codable + PropertyWrapper = ☕

**CodableWrapper** 是一个基于Swift的PropertyWrapper特性，为Codable协议提供额外能力的库。
基于原生JSONEncoder和JSONDecoder，无任何其他依赖。

---

## Feature
* 基于原生JSONEncoder和JSONDecoder，可插拔无负担
* DefaultValue
* 多CodingKey支持
* 自定义Transform支持，不需要值遵循Codable协议
* Optional支持良好
* BasicTypeBridge容错能力，String Number Bool 等基本类型自动互转

---
## Improvement

相比于用泛型记录某一信息量的库 [BetterCodable](https://github.com/marksands/BetterCodable)   [CodableWrappers](https://github.com/GottaGetSwifty/CodableWrappers)，本库找到了一种可以记录自定义配置的方法，扩展性强了不少，可自行实现TransformType协议做定制化的事情。

---

## Example

```Swift
struct NonCodable {
    var value: String?
}

struct ExampleModel: Codable {
    @CodableWrapper(codingKeys: ["stringVal", "string_Val"], defaultValue: "abc")
    var stringVal: String

    @CodableWrapper(codingKeys: ["int_Val", "intVal"], defaultValue: 123456)
    var intVal: Int

    @CodableWrapper(defaultValue: [1.998, 2.998, 3.998])
    var array: [Double]

    @CodableWrapper(defaultValue: false)
    var bool: Bool

    @CodableWrapper(transformer: TransformOf<NonCodable, String?>(fromNull: { NonCodable() }, 
                                                                  fromJSON: { NonCodable(value: $0) },
                                                                  toJSON: { $0.value }))
    var nonCodable: NonCodable

    @CodableWrapper(defaultValue: "default unImpl value")
    var unImpl: String
}


let json = """
{"int_Val": "233", "string_Val": "opq", "bool": "1", "nonCodable": "ok"}
"""

let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
XCTAssertEqual(model.intVal, 233)
XCTAssertEqual(model.stringVal, "opq")
XCTAssertEqual(model.unImpl, "default unImpl value")
XCTAssertEqual(model.array, [1.998, 2.998, 3.998])
XCTAssertEqual(model.bool, true)
XCTAssertEqual(model.nonCodable.value, "ok")
```

---
## Installation

#### Cocoapods
pod 'CodableWrapper'

#### Swift Package Manager
Select File > Swift Packages > Add Package Dependency. Enter https://github.com/winddpan/CodableWrapper in the "Choose Package Repository" dialog.

---


### DefaultValue（需要属性实现Codable协议）
```swift
struct ExampleModel: Codable {
    @CodableWrapper(defaultValue: false)
    var bool: Bool
}

let json = """
{"bool":"wrong value"}
"""

let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
XCTAssertEqual(model.bool, false)
```

### CodingKeys （Decode时会依次尝试，Encode时会使用第一个CodingKey作为JSON的键值
```swift
struct ExampleModel: Codable {
    @CodableWrapper(codingKeys: ["int_Val", "intVal"], defaultValue: 123456)
    var intVal: Int

    // Optional可以省略defaultValue，默认为nil
    @CodableWrapper(codingKeys: ["intOptional", "int_optional"])
    var intOptional: Int?
}

let json = """
{"int_Val": "233", "int_optional": 234}
"""

let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
XCTAssertEqual(model.intVal, 233)
XCTAssertEqual(model.intOptional, 234)

let data = try JSONEncoder().encode(model)
let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
XCTAssertEqual(jsonObject["int_Val"] as? Int, 233)
XCTAssertEqual(jsonObject["intOptional"] as? Int, 234)

```

### Transform
```swift
enum EnumInt: Int {
    case none, first, second, third
}
struct ExampleModel: Codable {
    @CodableWrapper(codingKeys: ["enum", "enumValue"],
                    transformer: TransformOf<EnumInt, Int>(fromNull: { EnumInt.none }, fromJSON: { EnumInt(rawValue: $0 + 1) }, toJSON: { $0.rawValue }))
    var enumValue: EnumInt
}

let json = """
{"enumValue": 2}
"""

let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
XCTAssertEqual(model.enumValue, EnumInt.third)

let jsonData = try JSONEncoder().encode(model)
let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
XCTAssertEqual(jsonObject["enum"] as? Int, 3)

let json2 = """
{"enum": 233}
"""
let model2 = try JSONDecoder().decode(ExampleModel.self, from: json2.data(using: .utf8)!)
XCTAssertEqual(model2.enumValue, EnumInt.none)
```

### BasicTypeBridge

```swift
struct ExampleModel: Codable {
    // test init()
    @CodableWrapper()
    var int: Int?
    
    @CodableWrapper
    var string: String?

    @CodableWrapper
    var bool: Bool?
}

let json = """
{"int": "1", "string": 2, "bool": "true"}
"""

let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
XCTAssertEqual(model.int, 1)
XCTAssertEqual(model.string, "2")
XCTAssertEqual(model.bool, true)
```

---

## BuiltIn Transfroms

### SecondsDateTransform / MillisecondDateTransform

```swift
struct ExampleModel: Codable {
    @CodableWrapper(transformer: SecondsDateTransform())
    var sencondsDate: Date

    @CodableWrapper(transformer: MillisecondDateTransform())
    var millSecondsDate: Date
}

let date = Date()
let json = """
{"sencondsDate": \(date.timeIntervalSince1970), "millSecondsDate": \(date.timeIntervalSince1970 * 1000)}
"""

let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
XCTAssertEqual(model.sencondsDate.timeIntervalSince1970, date.timeIntervalSince1970)
XCTAssertEqual(model.millSecondsDate.timeIntervalSince1970, date.timeIntervalSince1970)
```

OmitCoding

```swift
struct ExampleModel: Codable {
    @CodableWrapper(transformer: OmitEncoding())
    var omitEncoding: String?

    @CodableWrapper(transformer: OmitDecoding())
    var omitDecoding: String?
}

let json = """
{"omitEncoding": 123, "omitDecoding": "abc"}
"""

let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
XCTAssertEqual(model.omitEncoding, "123")
XCTAssertEqual(model.omitDecoding, nil)

let data = try JSONEncoder().encode(model)
let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
XCTAssertEqual(jsonObject["omitEncoding"] as? String, nil)
XCTAssertEqual(jsonObject["omitDecoding"] as? String, nil)
```

