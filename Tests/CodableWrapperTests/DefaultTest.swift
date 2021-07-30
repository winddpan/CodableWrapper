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
        @Codec("stringVal", "string_Val")
        var stringVal: String = "scyano"

        @Codec("int_Val", "intVal")
        var intVal: Int = 123456

        @Codec var array: [Double] = [1.998, 2.998, 3.998]

        @Codec var bool: Bool = false
        
        @Codec var unImpl: String?

        @Codec(transformer: TransformOf<NonCodable?, String?>(fromNull: { NonCodable() }, fromJSON: { NonCodable(value: $0) }, toJSON: { $0?.value }))
        var nonCodable: NonCodable?
//        
    }

    struct SimpleModel: Codable {
        @Codec var val: Int = 2
    }

    struct RootModel: Codable {
        var root: ExampleModel
    }

    struct OptionalModel: Codable {
        @Codec var val: String? = "default"
    }

    struct Optional2Model: Codable {
        @Codec("val2") var val: String?
    }

    func testCodingKeyDecode() throws {
        let json = """
        {"int_Val": "233", "string_Val": "pan", "bool": "1", "nonCodable": "ok"}
        """
        let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.intVal, 233)
        XCTAssertEqual(model.stringVal, "pan")
        XCTAssertEqual(model.unImpl, nil)
        XCTAssertEqual(model.array, [1.998, 2.998, 3.998])
        XCTAssertEqual(model.bool, true)
        // TODO: XCTAssertEqual failed: ("nil") is not equal to ("Optional("ok")")
        // 是否需要支持 non-Codable 类型
        XCTAssertEqual(model.nonCodable?.value, "ok")
    }

    func testCodingKeyEncode() throws {
        let json = """
        {"int_Val": 233, "string_Val": "pan"}
        """
        let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)

        let data = try JSONEncoder().encode(model)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        XCTAssertEqual(jsonObject["int_Val"] as? Int, 233)
        XCTAssertEqual(jsonObject["stringVal"] as? String, "pan")
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
                    XCTAssertEqual(model.stringVal, "scyano")
                    XCTAssertEqual(model.unImpl, nil)
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
                    XCTAssertEqual(model.unImpl, nil)
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
