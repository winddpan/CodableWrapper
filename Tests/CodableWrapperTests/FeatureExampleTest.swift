//
//  FeatureExampleTest.swift
//  CodableWrapperTest
//
//  Created by winddpan on 2020/8/21.
//

import CodableWrapper
import XCTest

class FeatureExampleTest: XCTestCase {
    func testDefaultVale() throws {
        struct ExampleModel: Codable {
            @CodableWrapper(defaultValue: false)
            var bool: Bool
        }
        let json = """
        {"bool":"wrong value"}
        """
        let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.bool, false)
    }

    func testCodingKeys() throws {
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
    }
    
    func testCustomTransform() throws {
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
    }
    
    func testBasicTypeBridge() throws {
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
    }
}
