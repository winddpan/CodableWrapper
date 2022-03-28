<p align="center">
  <h3 align="center">CodableWrapper</h3>
  <p align="center">
    Codable + PropertyWrapper = @Codec("encoder", "decoder") var cool: Bool = true
  </p>
</p>
<ol>
  <li><a href="#关于">关于</a></li>
  <li><a href="#功能">功能</a></li>
  <li><a href="#安装">安装</a></li>
  <li><a href="#一个例子">一个例子</a></li>
  <li><a href="#工作原理">工作原理</a></li>
  <li>
    <a href="#用法">用法</a>
    <ul>
      <li><a href="#缺省值">缺省值</a></li>
      <li><a href="#自定义解析key">自定义解析key</a></li>
      <li><a href="#基本类型互转">基本类型互转</a></li>
      <li><a href="#自定义解析规则">自定义解析规则</a></li>
    </ul>
  </li>
</ol>


## 关于
* 使用 `PropertyWrapper` 提升 `Codable` 的使用体验
* 基于系统 `JSONEncoder` `JSONDecoder`，无第三方依赖
* 比其他 Codable PropertyWrapper 的库相比 API更自由，比如 [BetterCodable](https://github.com/marksands/BetterCodable)  [CodableWrappers](https://github.com/GottaGetSwifty/CodableWrappers) 。它们都是使用泛型关联配置的，本库可以传参配置。

## 功能

* 基于 Codable，Codable 的基本能力都支持
* 支持缺省值
* 支持 `String`  `Bool` `Number` 等基本类型互转
* 自定义解析key
* JSON缺少字段容错
* 自定义解析规则

## 安装

#### Cocoapods
``` pod 'CodableWrapper' ```

#### Swift Package Manager
``` https://github.com/winddpan/CodableWrapper ```

## 一个例子
```Swift
enum Animal: String, Codable {
    case dog
    case cat
    case fish
}

struct ExampleModel: Codable {
    @Codec("aString")
    var stringVal: String = "scyano"

    @Codec("aInt")
    var intVal: Int = 123456

    @Codec var defaultArray: [Double] = [1.998, 2.998, 3.998]

    @Codec var bool: Bool = false

    @Codec var unImpl: String?
    
    @Codec var animal: Animal = .dog
}

let json = #"{"aString": "pan", "aInt": "233", "bool": "1", "animal": "cat"}"#

let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
XCTAssertEqual(model.stringVal, "pan")
XCTAssertEqual(model.intVal, 233)
XCTAssertEqual(model.defaultArray, [1.998, 2.998, 3.998])
XCTAssertEqual(model.bool, true)
XCTAssertEqual(model.unImpl, nil)
XCTAssertEqual(model.animal, .cat)
```

*查看 unit tests 或者 Playground 获取更多使用姿势*

## 工作原理
>怎么传递配置信息

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


## 用法

#### 缺省值
> 缺省值需要遵从 `Codable` 协议
```swift
struct ExampleModel: Codable {
    @Codec var bool: Bool = false
}

let json = #"{"bool":"wrong value"}"#

let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
XCTAssertEqual(model.bool, false)
```

#### 驼峰下划线自动互转
```swift
struct ExampleModel: Codable {
    @Codec var snake_string: String = ""
    @Codec var camelString: String = ""
}

let json = #"{"snakeString":"snake", "camel_string": "camel"}"#

let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
XCTAssertEqual(model.snake_string, "snake")
XCTAssertEqual(model.camelString, "camel")
```

#### 自定义解析key 
> Decoding:  左右往右尝试直到解析成功  
> Encoding:  使用第一 key作为JSON字典的key
```swift
struct ExampleModel: Codable {
    @Codec("int_Val", "intVal")
    var intVal: Int = 123456

    @Codec("intOptional", "int_optional")
    var intOptional: Int?
}

let json = #"{"int_Val": "233", "int_optional": 234}"#

let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
XCTAssertEqual(model.intVal, 233)
XCTAssertEqual(model.intOptional, 234)

let data = try JSONEncoder().encode(model)
let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
XCTAssertEqual(jsonObject["int_Val"] as? Int, 233)
XCTAssertEqual(jsonObject["intOptional"] as? Int, 234)

```

#### 基本类型互转
```swift
struct ExampleModel: Codable {
    @Codec var int: Int?
    @Codec var string: String?
    @Codec var bool: Bool?
}

let json = #"{"int": "1", "string": 2, "bool": "true"}"#

let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
XCTAssertEqual(model.int, 1)
XCTAssertEqual(model.string, "2")
XCTAssertEqual(model.bool, true)
```

#### 自定义解析规则
```swift
struct User: Codable {
    @Codec(transformer: SecondDateTransform())
    var registerDate: Date?
}       
let date = Date()
let json = #"{"sencondsDate": \(date.timeIntervalSince1970)}"#

let user = try JSONDecoder().decode(User.self, from: json.data(using: .utf8)!)
XCTAssertEqual(model.sencondsDate?.timeIntervalSince1970, date.timeIntervalSince1970)
```

> `TransfromType`协议支持自定义Transform

## License

Distributed under the MIT License. See `LICENSE` for more information.
