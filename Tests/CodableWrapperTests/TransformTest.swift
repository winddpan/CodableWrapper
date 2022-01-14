//
//  TransformTest.swift
//  CodableWrapperTest
//
//  Created by winddpan on 2020/8/21.
//

import CodableWrapper
import XCTest

class TransformTest: XCTestCase {
    struct ValueWrapper: Equatable {
        var value: String?
    }

    struct ExampleModel: Codable {
        @Codec(transformer: TransformOf<ValueWrapper, String>(fromJSON: { ValueWrapper(value: $0) }, toJSON: { $0.value }))
        var valueA = ValueWrapper(value: "A")

        @Codec(transformer: TransformOf<ValueWrapper?, String>(fromJSON: { ValueWrapper(value: $0) }, toJSON: { $0?.value }))
        var valueB = ValueWrapper(value: "B")

        @Codec(transformer: TransformOf<ValueWrapper?, String>(fromJSON: { $0 != nil ? ValueWrapper(value: $0) : nil }, toJSON: { $0?.value }))
        var valueC = ValueWrapper(value: "C")

        @Codec(transformer: TransformOf<ValueWrapper?, String>(fromJSON: { $0 != nil ? ValueWrapper(value: $0) : nil }, toJSON: { $0?.value }))
        var valueD: ValueWrapper?
    }

    func testTransformOf() throws {
        let fullModel = try JSONDecoder().decode(ExampleModel.self, from: #"{"valueA": "something_a", "valueB": "something_b", "valueC": "something_c", "valueD": "something_d"}"#.data(using: .utf8)!)
        let emptyModel = try JSONDecoder().decode(ExampleModel.self, from: #"{}"#.data(using: .utf8)!)

        XCTAssertEqual(fullModel.valueA, ValueWrapper(value: "something_a"))
        XCTAssertEqual(fullModel.valueB, ValueWrapper(value: "something_b"))
        XCTAssertEqual(fullModel.valueC, ValueWrapper(value: "something_c"))
        XCTAssertEqual(fullModel.valueD, ValueWrapper(value: "something_d"))

        XCTAssertEqual(emptyModel.valueA, ValueWrapper(value: nil))
        XCTAssertEqual(emptyModel.valueB, ValueWrapper(value: nil))
        XCTAssertEqual(emptyModel.valueC, ValueWrapper(value: "C"))
        XCTAssertEqual(emptyModel.valueD, nil)
    }

    func testCustomUnOptionalTransform() throws {
        struct ExampleModel: Codable {
            @Codec(transformer: EnumInt.transformer)
            var one: EnumInt = .three

            @Codec(transformer: EnumInt.transformer)
            var two: EnumInt?
        }

        let json = "{}"
        let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.one, .zero)
        XCTAssertEqual(model.two, .zero)
    }

    func testCustomOptionalTransform() throws {
        struct ExampleModel: Codable {
            @Codec(transformer: EnumInt.optionalTransformer)
            var one: EnumInt = .three

            @Codec(transformer: EnumInt.optionalTransformer)
            var two: EnumInt?
        }

        let json = "{}"
        let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.one, EnumInt.three)
        XCTAssertEqual(model.two, nil)
    }

    func testCustomTransformCodec() throws {
        struct ExampleModel: Codable {
            @Codec
            var id: Int = 0

            @Codec(["tuple", "tp"], transformer: tupleTransform)
            var tuple: (String, String)?

            @Codec(transformer: tupleTransform)
            var tupleOptional: (String, String)?
        }

        let json = """
        {"id": 1, "tp": "left|right"}
        """
        let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.id, 1)
        XCTAssertEqual(model.tuple?.0, "left")
        XCTAssertEqual(model.tuple?.1, "right")
        XCTAssertEqual(model.tupleOptional?.0, nil)

        let jsonData = try JSONEncoder().encode(model)
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
        XCTAssertEqual(jsonObject["id"] as? Int, 1)
        XCTAssertEqual(jsonObject["tuple"] as? String, "left|right")
//        XCTAssertEqual(String(data: jsonData, encoding: .utf8), "{\"id\":1,\"tuple\":\"left|right\"}")
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

let tupleTransform = TransformOf<(String, String)?, String>(fromJSON: { json in
    if let json = json {
        let comps = json.components(separatedBy: "|")
        return (comps.first ?? "", comps.last ?? "")
    }
    return nil
}, toJSON: { tuple in
    if let tuple = tuple {
        return "\(tuple.0)|\(tuple.1)"
    }
    return nil
})

enum EnumInt: Int {
    case zero, one, two, three

    static var transformer: TransformOf<EnumInt, Int> {
        return TransformOf(fromJSON: { json in
                               if let json = json, let result = EnumInt(rawValue: json) {
                                   return result
                               }
                               return .zero
                           },
                           toJSON: { $0.rawValue })
    }

    static var optionalTransformer: TransformOf<EnumInt?, Int> {
        return TransformOf(fromJSON: { json in
                               if let json = json, let result = EnumInt(rawValue: json) {
                                   return result
                               }
                               return nil
                           },
                           toJSON: { $0?.rawValue })
    }
}
