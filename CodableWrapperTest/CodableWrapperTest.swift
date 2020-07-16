//
//  CodableWrapperTest.swift
//  CodableWrapperTest
//
//  Created by PAN on 2020/7/16.
//

import XCTest
import CodableWrapper

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


class CodableWrapperTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        do {
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
            
            for i in 0...10 {
                let json = """
                {"value": {"intVal": \(i)}}
                """
                let model = try JSONDecoder().decode(Level1Model.self, from: json.data(using: .utf8)!)
                XCTAssertEqual(model.value.intVal, i)
                XCTAssertEqual(model.value.stringVal, "abc")
                XCTAssertEqual(model.value.unImpl, "default unImpl value")
                XCTAssertEqual(model.value.array, [1.998, 2.998, 3.998])
            }
            
        } catch let e {
            print(e)
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
