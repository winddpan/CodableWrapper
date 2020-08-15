//
//  CodableWrapperTest.swift
//  CodableWrapperTest
//
//  Created by PAN on 2020/7/16.
//

import CodableWrapper
import XCTest

struct ExampleModel: Codable {
    @CodableWrapper(defaultValue: "default unImpl value")
    var unImpl: String

    @CodableWrapper(codingKeys: ["stringVal", "string_Val"], defaultValue: "abc")
    var stringVal: String

    @CodableWrapper(codingKeys: ["int_Val", "intVal"], defaultValue: 123456)
    var intVal: Int

    @CodableWrapper(defaultValue: [1.998, 2.998, 3.998])
    var array: [Double]
}

struct RootModel: Codable {
    var root: ExampleModel
}

class CodableWrapperTest: XCTestCase {
    func testCodingKeyDecode() throws {
        let json = """
        {"int_Val": 233, "string_Val": "opq"}
        """
        let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.intVal, 233)
        XCTAssertEqual(model.stringVal, "opq")
        XCTAssertEqual(model.unImpl, "default unImpl value")
        XCTAssertEqual(model.array, [1.998, 2.998, 3.998])
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
