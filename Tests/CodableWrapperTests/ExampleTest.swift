////
////  ExampleTest.swift
////  CodableWrapperTest
////
////  Created by PAN on 2020/7/16.
////
//
import CodableWrapper
import XCTest
//
///** Model */
//
//typealias JSONDecoder = CodableWrapper.JSONDecoder
//typealias JSONEncoder = CodableWrapper.JSONEncoder
//typealias JSONSerialization = CodableWrapper.JSONSerialization

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

    @Codec var array: [Double] = [1.998, 2.998, 3.998]

    @Codec var bool: Bool = false

    @Codec var bool2: Bool = true

    @Codec var unImpl: String?

    @Codec var animal: Animal = .dog
}

struct SimpleModel: Codable {
    @Codec var val: Int = 2
}

struct OptionalModel: Codable {
    @Codec var val: String? = "default"
}

struct OptionalNullModel: Codable {
    @Codec var val: String?
}

/** ExampleTest */

class ExampleTest: XCTestCase {
    
    override class func setUp() {
        CodableWrapperRegisterAdditionalCoder {
            try JSONDecoder().decode(CodablePrepartion.self, from: $0)
        } encode: {
            try JSONEncoder().encode($0)
        }

    }
    
    func testBasicUsage() throws {
        let json = #"{"stringVal": "pan", "intVal": "233", "bool": "1", "animal": "cat"}"#
        let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.intVal, 233)
        XCTAssertEqual(model.stringVal, "pan")
        XCTAssertEqual(model.unImpl, nil)
        XCTAssertEqual(model.array, [1.998, 2.998, 3.998])
        XCTAssertEqual(model.bool, true)
        XCTAssertEqual(model.animal, .cat)
    }

    func testCodingKeyEncode() throws {
        let json = """
        {"intVal": 233, "stringVal": "pan"}
        """
        let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)

        let data = try JSONEncoder().encode(model)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        XCTAssertEqual(jsonObject["aInt"] as? Int, 233)
        XCTAssertEqual(jsonObject["aString"] as? String, "pan")
    }
//
    func testSnakeCamel() throws {
        struct ExampleModel: Codable {
            @Codec var snake_string: String = ""
            @Codec var camelString: String = ""
        }

        let json = #"{"snakeString":"snake", "camel_string": "camel"}"#

        let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.snake_string, "snake")
        XCTAssertEqual(model.camelString, "camel")
    }

    func testCodingKeyDecode() throws {
        let json = """
        {"aString": "pan", "aInt": "233"}
        """
        let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.intVal, 233)
        XCTAssertEqual(model.stringVal, "pan")
    }

    func testDefaultVale() throws {
        let json = """
        {"intVal": "wrong value"}
        """
        let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.intVal, 123456)
        XCTAssertEqual(model.stringVal, "scyano")
        XCTAssertEqual(model.animal, .dog)
    }

    func testNested() throws {
        struct RootModel: Codable {
            @Codec("rt") var root = SubRootModelCodec()
            var root2: SubRootModel? = SubRootModel()
        }

        struct SubRootModelCodec: Codable {
            @Codec var value: ExampleModel?
            @Codec var value2 = ExampleModel()
        }

        struct SubRootModel: Codable {
            var value: ExampleModel?
            var value2: ExampleModel? = ExampleModel()
        }

        let json = """
        {"rt": {"value": {"stringVal":"x"}}, "root2": {"value": {"stringVal":"y"}}}
        """
        let model = try JSONDecoder().decode(RootModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.root.value?.stringVal, "x")
        XCTAssertEqual(model.root.value2.stringVal, "scyano")
        XCTAssertEqual(model.root2?.value?.stringVal, "y")
        XCTAssertEqual(model.root2?.value2?.stringVal, nil)
    }

    func testOptionalWithValue() throws {
        let json = """
        {"val": "default2"}
        """
        let model = try JSONDecoder().decode(OptionalModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.val, "default2")
    }

    func testOptionalWithNull() throws {
        let json = """
        {"val": null}
        """
        let model = try JSONDecoder().decode(OptionalNullModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.val, nil)

        let json2 = """
        {}
        """
        let model2 = try JSONDecoder().decode(OptionalNullModel.self, from: json2.data(using: .utf8)!)
        XCTAssertEqual(model2.val, nil)
    }

    func testBasicTypeBridge() throws {
        let json = """
        {"intVal": "1", "stringVal": 2, "bool": "true"}
        """
        let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.intVal, 1)
        XCTAssertEqual(model.stringVal, "2")
        XCTAssertEqual(model.bool, true)

        let jsonData = try JSONEncoder().encode(model)
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
        XCTAssertEqual(jsonObject["aString"] as? String, "2")
    }

    func testMutiThread() throws {
        let expectation = XCTestExpectation(description: "")
        let expectation2 = XCTestExpectation(description: "")

        var array: [ExampleModel] = []
        var array2: [ExampleModel] = []

        DispatchQueue.global().async {
            do {
                for i in 5000 ..< 6000 {
                    let json = """
                    {"intVal": \(i)}
                    """
                    let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
                    XCTAssertEqual(model.intVal, i)
                    XCTAssertEqual(model.stringVal, "scyano")
                    XCTAssertEqual(model.unImpl, nil)
                    XCTAssertEqual(model.array, [1.998, 2.998, 3.998])
                    // print(model.intVal)

                    array.append(model)
                }
                expectation.fulfill()
            } catch let e {
                print(e)
            }
        }

        DispatchQueue.global().async {
            do {
                for i in 1 ..< 1000 {
                    let json = """
                    {"intVal": \(i), "stringVal": "string_\(i)", "array": [123456789]}
                    """
                    let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
                    XCTAssertEqual(model.intVal, i)
                    XCTAssertEqual(model.stringVal, "string_\(i)")
                    XCTAssertEqual(model.unImpl, nil)
                    XCTAssertEqual(model.array, [123456789])

                    array2.append(model)
                }
                expectation2.fulfill()
            } catch let e {
                print(e)
            }
        }

        wait(for: [expectation, expectation2], timeout: 10.0)
    }
}
