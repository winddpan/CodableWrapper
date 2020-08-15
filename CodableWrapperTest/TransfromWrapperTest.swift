//
//  TransfromWrapperTest.swift
//  CodableWrapperTest
//
//  Created by winddpan on 2020/8/16.
//

import CodableWrapper
import XCTest

enum Enum: String {
    case a, b, c
}

class TransfromExampleModel: Codable {
    @TransformWrapper(codingKeys: ["enum", "enumValue"], fromNil: { Enum.a }, fromJSON: { Enum(rawValue: $0) }, toJSON: { $0.rawValue })
    var enumValue: Enum
    
    @TransformWrapper(codingKeys: ["str"], fromNil: { "" }, as: Int.self)
    var string_Int: String
}

class TransfromWrapperTest: XCTestCase {
//    func testTransfromer1() throws {
//        let json = """
//        {"enum": "b"}
//        """
//        let model = try JSONDecoder().decode(TransfromExampleModel.self, from: json.data(using: .utf8)!)
//        XCTAssertEqual(model.enumValue, Enum.b)
//
//        let data = try JSONEncoder().encode(model)
//        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
//        XCTAssertEqual(jsonObject["enum"] as? String, "b")
//
//        let json2 = """
//        {}
//        """
//        let model2 = try JSONDecoder().decode(TransfromExampleModel.self, from: json2.data(using: .utf8)!)
//        XCTAssertEqual(model2.enumValue, Enum.a)
//    }

    func testTransfromer2() throws {
        let json = """
        {"str": 111}
        """
        let model = try JSONDecoder().decode(TransfromExampleModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.string_Int, "111")
        
        let data = try JSONEncoder().encode(model)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        XCTAssertEqual(jsonObject["str"] as? String, "111")
    }
}
