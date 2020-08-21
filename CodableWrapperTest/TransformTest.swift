//
//  TransformTest.swift
//  CodableWrapperTest
//
//  Created by winddpan on 2020/8/16.
//

import CodableWrapper
import XCTest

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
}

class TransformTest: XCTestCase {
    func testTransformer1() throws {
        let json = """
        {"enum": "b"}
        """
        let model = try JSONDecoder().decode(TransformExampleModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.enumValue, Enum.b)

        let data = try JSONEncoder().encode(model)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        XCTAssertEqual(jsonObject["enum"] as? String, "b")

        let json2 = """
        {}
        """
        let model2 = try JSONDecoder().decode(TransformExampleModel.self, from: json2.data(using: .utf8)!)
        XCTAssertEqual(model2.enumValue, Enum.a)
    }

    func testTransformer2() throws {
        let json = """
        {"str": 111, "str2": 222}
        """
        let model = try JSONDecoder().decode(TransformExampleModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.string_Int, "111")
        XCTAssertEqual(model.ok, "222")

        let data = try JSONEncoder().encode(model)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        XCTAssertEqual(jsonObject["str"] as? Int, 111)
    }
    
    func testTransformer3() throws {
        let json = """
        {"omitEncoding": 123, "omitDecoding": "abc"}
        """
        let model = try JSONDecoder().decode(TransformExampleModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.omitEncoding, "123")
        XCTAssertEqual(model.omitDecoding, nil)

        let data = try JSONEncoder().encode(model)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        XCTAssertEqual(jsonObject["omitEncoding"] as? String, nil)
        XCTAssertEqual(jsonObject["omitDecoding"] as? String, nil)
    }
}
