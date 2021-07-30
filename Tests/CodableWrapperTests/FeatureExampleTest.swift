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
            @Codec var bool: Bool = false
        }
        let json = """
        {"bool":"wrong value"}
        """
        let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.bool, false)
    }

    func testCodingKeys() throws {
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
    }

    func testCustomTransform() throws {
        enum EnumInt: Int {
            case none, first, second, third
        }
        struct ExampleModel: Codable {
            @Codec("enum", "enumValue", transformer: TransformOf(fromNull: { .none }, fromJSON: { EnumInt(rawValue: $0 + 1) }, toJSON: { $0.rawValue }))
            var enumValue: EnumInt = .none
            
            @Codec(transformer: TransformOf(fromNull: { .none }, fromJSON: { EnumInt(rawValue: $0) }, toJSON: { $0.rawValue }))
            var enumOptional: EnumInt?
        }

        let json = """
        {"enumValue": 2, "enumOptional": 1}
        """
        let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.enumValue, EnumInt.third)
        XCTAssertEqual(model.enumOptional, EnumInt.first)

        let jsonData = try JSONEncoder().encode(model)
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
        XCTAssertEqual(jsonObject["enum"] as? Int, 3)
        XCTAssertEqual(jsonObject["enumOptional"] as? Int, 1)

        let json2 = """
        {"enum": 233}
        """
        let model2 = try JSONDecoder().decode(ExampleModel.self, from: json2.data(using: .utf8)!)
        XCTAssertEqual(model2.enumValue, EnumInt.none)
    }

    func testBasicTypeBridge() throws {
        struct ExampleModel: Codable {
            // test init()
            @Codec()
            var int: Int?

            @Codec
            var string: String?

            @Codec
            var bool: Bool?
        }

        let json = """
        {"int": "1", "string": 2, "bool": "true"}
        """
        let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.int, 1)
        XCTAssertEqual(model.string, "2")
        XCTAssertEqual(model.bool, true)

        let jsonData = try JSONEncoder().encode(model)
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
        XCTAssertEqual(jsonObject["string"] as? String, "2")
    }
}
