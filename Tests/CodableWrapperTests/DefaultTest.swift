//
//  CodableWrapperTest.swift
//  CodableWrapperTest
//
//  Created by PAN on 2020/7/16.
//

import CodableWrapper
import XCTest

class DefaultTest: XCTestCase {
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

        @CodableWrapper(transformer: TransformOf<NonCodable, String?>(fromNull: { NonCodable() }, fromJSON: { NonCodable(value: $0) }, toJSON: { $0.value }))
        var nonCodable: NonCodable

        @CodableWrapper(defaultValue: "default unImpl value")
        var unImpl: String
    }

    struct SimpleModel: Codable {
        @CodableWrapper(defaultValue: 2)
        var val: Int
    }

    struct RootModel: Codable {
        var root: ExampleModel
    }

    struct OptionalModel: Codable {
        @CodableWrapper(defaultValue: "default")
        var val: String?
    }

    struct Optional2Model: Codable {
        @CodableWrapper(codingKeys: ["val2"], defaultValue: nil)
        var val: String?
    }

    func testCodingKeyDecode() throws {
        let json = """
        {"int_Val": "233", "string_Val": "opq", "bool": "1", "nonCodable": "ok"}
        """
        let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.intVal, 233)
        XCTAssertEqual(model.stringVal, "opq")
        XCTAssertEqual(model.unImpl, "default unImpl value")
        XCTAssertEqual(model.array, [1.998, 2.998, 3.998])
        XCTAssertEqual(model.bool, true)
        // TODO: XCTAssertEqual failed: ("nil") is not equal to ("Optional("ok")")
        // 是否需要支持 non-Codable 类型
        XCTAssertEqual(model.nonCodable.value, "ok")
    }

    func testCodingKeyEncode() throws {
        let json = """
        {"int_Val": 233, "string_Val": "opq"}
        """
        let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)

        let data = try JSONEncoder().encode(model)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        XCTAssertEqual(jsonObject["int_Val"] as? Int, 233)
        XCTAssertEqual(jsonObject["stringVal"] as? String, "opq")
    }

    func testNested() throws {
        let json = """
        {"root": {"stringVal":"x"}}
        """
        let model = try JSONDecoder().decode(RootModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.root.stringVal, "x")
    }

    func testOptional() throws {
        let json = """
        {"val": "default2"}
        """
        let model = try JSONDecoder().decode(OptionalModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.val, "default2")
    }

    func testOptional2() throws {
        let json = """
        {"val2": null}
        """
        let model = try JSONDecoder().decode(Optional2Model.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.val, nil)
    }

    func testMutiThread() throws {
        let expectation = XCTestExpectation(description: "")
        let expectation2 = XCTestExpectation(description: "")

        DispatchQueue.global().async {
            do {
                for i in 5000 ... 6000 {
                    let json = """
                    {"int_Val": \(i)}
                    """
                    let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
                    XCTAssertEqual(model.intVal, i)
                    XCTAssertEqual(model.stringVal, "abc")
                    XCTAssertEqual(model.unImpl, "default unImpl value")
                    XCTAssertEqual(model.array, [1.998, 2.998, 3.998])
                    // print(model.intVal)
                }
                expectation.fulfill()
            } catch let e {
                print(e)
            }
        }

        DispatchQueue.global().async {
            do {
                for i in 1 ... 1000 {
                    let json = """
                    {"int_Val": \(i), "string_Val": "string_\(i)", "array": [123456789]}
                    """
                    let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
                    XCTAssertEqual(model.intVal, i)
                    XCTAssertEqual(model.stringVal, "string_\(i)")
                    XCTAssertEqual(model.unImpl, "default unImpl value")
                    XCTAssertEqual(model.array, [123456789])
                    // print(model.stringVal)
                }
                expectation2.fulfill()
            } catch let e {
                print(e)
            }
        }

        wait(for: [expectation, expectation2], timeout: 10.0)
    }
}
