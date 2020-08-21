# CodableWrapper
CodableWrapper

---

# Example

```
enum Enum: String {
    case a, b, c
}

class TransformExampleModel: Codable {
    @CodableWrapper(codingKeys: ["enum", "enumValue"],
                    transformer: TransformOf<Enum, String>(fromNull: { Enum.a }, fromJSON: { Enum(rawValue: $0) }, toJSON: { $0.rawValue }))
    var enumValue: Enum

    @CodableWrapper(codingKeys: ["str"], fromNull: { "" }, fromJSON: { "\($0)" }, toJSON: { Int($0) })
    var string_Int: String

    @CodableWrapper(codingKeys: ["str2"])
    var ok: String?

    @CodableWrapper(transformer: OmitEncoding())
    var omitEncoding: String?

    @CodableWrapper(transformer: OmitDecoding())
    var omitDecoding: String?

    @CodableWrapper(transformer: SecondsDateTransform())
    var date: Date
    
    @CodableWrapper(transformer: MillisecondDateTransform())
    var millSecondsDate: Date
}
```
```
let json = """
{"enum": "b"}
"""
let model = try JSONDecoder().decode(TransformExampleModel.self, from: json.data(using: .utf8)!)
XCTAssertEqual(model.enumValue, Enum.b)

```

```
struct ExampleModel: Codable {
    @CodableWrapper(defaultValue: "default unImpl value")
    var unImpl: String

    @CodableWrapper(codingKeys: ["stringVal", "string_Val"], defaultValue: "abc")
    var stringVal: String

    @CodableWrapper(codingKeys: ["int_Val", "intVal"], defaultValue: 123456)
    var intVal: Int

    @CodableWrapper(defaultValue: [1.998, 2.998, 3.998])
    var array: [Double]
    
    @CodableWrapper(defaultValue: false)
    var bool: Bool
}
```
```
let json = """
{"int_Val": "233", "string_Val": "opq", "bool": "1"}
"""
let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
XCTAssertEqual(model.intVal, 233)
XCTAssertEqual(model.stringVal, "opq")
XCTAssertEqual(model.unImpl, "default unImpl value")
XCTAssertEqual(model.array, [1.998, 2.998, 3.998])
XCTAssertEqual(model.bool, true)
```

# Feature
* Thread safe
* Encode & Decode full support
* Custom Transfromer support
* Codable defaultValue
* CodingKey mapping
