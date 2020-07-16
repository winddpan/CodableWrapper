# CodableWrapper
CodableWrapper Experiment

---

# Example

```
struct ExampleModel: Codable {
    @CodableWrapper("intVal", default: 123456)
    var intVal: Int

    @CodableWrapper("stringVal", default: "abc")
    var stringVal: String
    
    @CodableWrapper("array", default: [1.998, 2.998, 3.998])
    var array: [Double]
    
    @CodableWrapper("unImpl", default: "default unImpl value")
    var unImpl: String
}

struct Level1Model: Codable {
    var value: ExampleModel
}
```

```
for i in 0...10 {
    let json = """
    {"value": {"intVal": \(i), "stringVal": "string_\(i)", "array": [123456789]}}
    """

    let model = try JSONDecoder().decode(Level1Model.self, from: json.data(using: .utf8)!)
    XCTAssertEqual(model.value.intVal, i)
    XCTAssertEqual(model.value.stringVal, "string_\(i)")
    XCTAssertEqual(model.value.unImpl, "default unImpl value")
    XCTAssertEqual(model.value.array, [123456789])
}
```

# TODO
* Transfrom support
* Unit test coverage
