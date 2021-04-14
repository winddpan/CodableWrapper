<p align="center">
  <h3 align="center">CodableWrapper</h3>
  <p align="center">
    Codable + PropertyWrapper = ☕
  </p>
</p>
<ol>
  <li><a href="#about-the-project">About The Project</a></li>
  <li><a href="#installation">Installation</a></li>
  <li><a href="#example">Example</a></li>
  <li><a href="#how-it-works">How it works</a></li>
  <li>
    <a href="#advanced-usage">Advanced usage</a>
    <ul>
      <li><a href="#defaultvalue">DefaultValue</a></li>
      <li><a href="#codingkeys">CodingKeys</a></li>
      <li><a href="#transform">Transform</a></li>
      <li><a href="#basictypebridge">BasicTypeBridge</a></li>
    </ul>
  </li>
  <li>
    <a href="#builtin-transfroms">BuiltIn Transfroms</a>
    <ul>
      <li><a href="#datetransform">DateTransform</a></li>
      <li><a href="#omitcoding">OmitCoding</a></li>
    </ul>
  </li>
  <li><a href="#license">License</a></li>
</ol>

## About The Project
* This project is use `PropertyWrapper` to improve your `Codable` use experience.
* Simply based on `JSONEncoder` `JSONDecoder`.
* Powerful and simplifily API than  [BetterCodable](https://github.com/marksands/BetterCodable) or [CodableWrappers](https://github.com/GottaGetSwifty/CodableWrappers).
* Pass configuration avaiable, `@CodableWrapper(codingKeys: ..., transformer: TransformOf<EnumInt, nt>(fromNull: { ... }, fromJSON: { ... }, toJSON: { ... }))`
* Implement your own `TransformType` to do more stuff.
* Auto fix basic type convertation, between `String` `Number` `Bool` ...

## Installation

#### Cocoapods
``` pod 'CodableWrapper' ```

#### Swift Package Manager
``` https://github.com/winddpan/CodableWrapper ```

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


## How it works
```Swift
struct DataModel: Codable {
    @CodableWrapper(defaultValue: "OK")
    var stringVal: String
}

/* Swift Build -> */
struct DataModel: Codable {
    var _stringVal = CodableWrapper<String>(defaultValue: "OK")

    var stringVal: String {
        get {
            return _stringVal.wrappedValue
        }
        set {
            _stringVal.wrappedValue = newValue
        }
    }

    enum CodingKeys: CodingKey {
        case stringVal
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        /* decode `newStringVal` */
        /* remember `newStringVal`: Thread.current.lastCodableWrapper = wrapper */
        /*
         extension KeyedDecodingContainer {
            func decode<Value>(_ type: CodableWrapper<Value>.Type, forKey key: Key) throws -> CodableWrapper<Value> {
                ...
                let wrapper = CodableWrapper<Value>(unsafed: ())
                Thread.current.lastCodableWrapper = wrapper
                ...
            }
         }
         */
        let newStringVal = try container.decode(CodableWrapper<String>.self, forKey: CodingKeys.stringVal)

        /* old `_stringVal` deinit */
        /* old `_stringVal` invokeAfterInjection called: transform old `_stringVal` Configs to `newStringVal` */
        /* 
         deinit {
             if !unsafeCreated, let construct = construct, let lastWrapper = Thread.current.lastCodableWrapper as? CodableWrapper<Value> {
                 lastWrapper.invokeAfterInjection(with: construct)
                 Thread.current.lastCodableWrapper = nil
             }
         }
        */
        self._stringVal = newStringVal
    }
}
```


## Advanced usage

#### DefaultValue
> DefaultValue should implement `Codable` protocol
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

#### CodingKeys 
> While Decoding: try each CodingKey until succeed; while Encoding: use first CodingKey as Dictionary key
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

#### Transform
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

#### BasicTypeBridge
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


## BuiltIn Transfroms

#### DateTransform
> SecondsDateTransform / MillisecondDateTransform

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

#### OmitCoding
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

## License
Distributed under the MIT License. See `LICENSE` for more information.
