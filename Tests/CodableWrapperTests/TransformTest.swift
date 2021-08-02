//
//  TransformTest.swift
//  CodableWrapperTest
//
//  Created by winddpan on 2020/8/21.
//

import CodableWrapper
import XCTest

class TransformTest: XCTestCase {
    func testCustomTransform() throws {
        enum EnumInt: Int {
            case none, first, second, third

            static var transformer: TransformOf<EnumInt, Int> {
                return TransformOf(fromNull: { .none },
                                   fromJSON: { EnumInt(rawValue: $0 + 1) },
                                   toJSON: { $0.rawValue })
            }

            static var transformerOptional: TransformOf<EnumInt?, Int> {
                return TransformOf<EnumInt?, Int>(fromNull: { nil },
                                                  fromJSON: { EnumInt(rawValue: $0 + 1) },
                                                  toJSON: { $0?.rawValue })
            }
        }
        struct ExampleModel: Codable {
            @Codec("enum", "enumValue", transformer: EnumInt.transformer)
            var enumValue: EnumInt = .none

            @Codec(transformer: EnumInt.transformer)
            var enumValue2: EnumInt?

            @Codec(transformer: EnumInt.transformerOptional)
            var enumOptional: EnumInt?
        }

        let json = """
        {"enumValue": 2, "enumOptional": 1}
        """
        let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.enumValue, EnumInt.third)
        XCTAssertEqual(model.enumValue2, EnumInt.none)
        XCTAssertEqual(model.enumOptional, EnumInt.second)

        let jsonData = try JSONEncoder().encode(model)
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
        XCTAssertEqual(jsonObject["enum"] as? Int, 3)
        XCTAssertEqual(jsonObject["enumOptional"] as? Int, 2)

        let json2 = """
        {"enum": 233}
        """
        let model2 = try JSONDecoder().decode(ExampleModel.self, from: json2.data(using: .utf8)!)
        XCTAssertEqual(model2.enumValue, EnumInt.none)
    }

    func testDateTransfrom() throws {
        struct ExampleModel: Codable {
            @Codec(transformer: SecondDateTransform())
            var sencondsDate: Date?

            @Codec(transformer: MillisecondDateTransform())
            var millSecondsDate: Date?
        }

        let date = Date()
        let json = """
        {"sencondsDate": \(date.timeIntervalSince1970), "millSecondsDate": \(date.timeIntervalSince1970 * 1000)}
        """

        let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.sencondsDate?.timeIntervalSince1970, date.timeIntervalSince1970)
        XCTAssertEqual(model.millSecondsDate?.timeIntervalSince1970, date.timeIntervalSince1970)
    }
}
