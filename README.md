<p align="center">
  <h3 align="center">CodableWrapper</h3>
  <p align="center">
    Codable + PropertyWrapper = @Codec("encoder", "decoder") var cool: Bool = true
  </p>
</p>
<ol>
  <li><a href="#about-the-project">About</a></li>
  <li><a href="#feature">Feature</a></li>
  <li><a href="#installation">Installation</a></li>
  <li><a href="#example">Example</a></li>
  <li><a href="#how-it-works">How it works</a></li>
  <li>
    <a href="#advanced-usage">Advanced usage</a>
    <ul>
      <li><a href="#defaultvalue">DefaultValue</a></li>
      <li><a href="#codingkeys">CodingKeys</a></li>
      <li><a href="#basictypebridge">BasicTypeBridge</a></li>
    </ul>
  </li>
  <li>
    <a href="#transformer">Transformer</a>
  </li>
</ol>


## About
* This project is use `PropertyWrapper` to improve your `Codable` use experience.
* Simply based on `JSONEncoder` `JSONDecoder`.
* Powerful and simplifily API than  [BetterCodable](https://github.com/marksands/BetterCodable) or [CodableWrappers](https://github.com/GottaGetSwifty/CodableWrappers).

## Feature

* Default value supported
* Basic type convertible, between `String`  `Bool` `Number` 
* Fix parsing failure due to missing fields from server
* Fix parsing failure due to mismatch Enum raw value

## Installation

#### Cocoapods
``` pod 'CodableWrapper' ```

#### Swift Package Manager
``` https://github.com/winddpan/CodableWrapper ```

## Example
```Swift
struct ExampleModel: Codable {
    @Codec("stringVal", "string_Val") 
    var stringVal: String = "scyano"
  
    @Codec("int_Val", "intVal") 
    var intVal: Int = 123456
  
    @Codec var array: [Double] = [1.998, 2.998, 3.998]
  
    @Codec var bool: Bool = false
  
    @Codec var unImpl: String?
}

let json = """
{"int_Val": "233", "string_Val": "pan", "bool": "1"}
"""

let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
XCTAssertEqual(model.intVal, 233)
XCTAssertEqual(model.stringVal, "pan")
XCTAssertEqual(model.unImpl, "nil")
XCTAssertEqual(model.array, [1.998, 2.998, 3.998])
XCTAssertEqual(model.bool, true)
```

*For more examples, please check the unit tests*

## How it works

```Swift
struct DataModel: Codable {
    @Codec var stringVal: String = "OK"
}

/* pseudocode from Swift open source lib: Codable.Swift -> */
struct DataModel: Codable {
    private var _stringVal = Codec<String>(defaultValue: "OK")

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
            func decode<Value>(_ type: Codec<Value>.Type, forKey key: Key) throws -> Codec<Value> {
                ...
                let wrapper = Codec<Value>(unsafed: ())
                Thread.current.lastCodableWrapper = wrapper
                ...
            }
         }
         */
        let newStringVal = try container.decode(Codec<String>.self, forKey: CodingKeys.stringVal)

        /* old `_stringVal` deinit */
        /* old `_stringVal` invokeAfterInjection called: transform old `_stringVal` Configs to `newStringVal` */
        /* 
         deinit {
             if !unsafeCreated, let construct = construct, let lastWrapper = Thread.current.lastCodableWrapper as? Codec<Value> {
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
    @Codec var bool: Bool = false
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
    @Codec("int_Val", "intVal")
    var intVal: Int = 123456

    @Codec("intOptional", "int_optional")
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

#### BasicTypeBridge
```swift
struct ExampleModel: Codable {
    @Codec var int: Int?
    
    @Codec var string: String?

    @Codec var bool: Bool?
}

let json = """
{"int": "1", "string": 2, "bool": "true"}
"""

let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
XCTAssertEqual(model.int, 1)
XCTAssertEqual(model.string, "2")
XCTAssertEqual(model.bool, true)
```

#### Transformer
```swift
struct ValueWrapper: Equatable {
    var value: String?
}

struct ExampleModel: Codable {
    @Codec(transformer: TransformOf<ValueWrapper, String>(fromJSON: { ValueWrapper(value: $0) }, toJSON: { $0.value }))
    var valueA = ValueWrapper(value: "A")

    @Codec(transformer: TransformOf<ValueWrapper?, String>(fromJSON: { ValueWrapper(value: $0) }, toJSON: { $0?.value }))
    var valueB = ValueWrapper(value: "B")

    @Codec(transformer: TransformOf<ValueWrapper?, String>(fromJSON: { $0 != nil ? ValueWrapper(value: $0) : nil }, toJSON: { $0?.value }))
    var valueC = ValueWrapper(value: "C")

    @Codec(transformer: TransformOf<ValueWrapper?, String>(fromJSON: { $0 != nil ? ValueWrapper(value: $0) : nil }, toJSON: { $0?.value }))
    var valueD: ValueWrapper?
}

let fullModel = try JSONDecoder().decode(ExampleModel.self, from: #"{"valueA": "something_a", "valueB": "something_b", "valueC": "something_c", "valueD": "something_d"}"#.data(using: .utf8)!)
let emptyModel = try JSONDecoder().decode(ExampleModel.self, from: #"{}"#.data(using: .utf8)!)

XCTAssertEqual(fullModel.valueA, ValueWrapper(value: "something_a"))
XCTAssertEqual(fullModel.valueB, ValueWrapper(value: "something_b"))
XCTAssertEqual(fullModel.valueC, ValueWrapper(value: "something_c"))
XCTAssertEqual(fullModel.valueD, ValueWrapper(value: "something_d"))

XCTAssertEqual(emptyModel.valueA, ValueWrapper(value: nil))
XCTAssertEqual(emptyModel.valueB, ValueWrapper(value: nil))
XCTAssertEqual(emptyModel.valueC, ValueWrapper(value: "C"))
XCTAssertEqual(emptyModel.valueD, nil)
```

## License
Distributed under the MIT License. See `LICENSE` for more information.
