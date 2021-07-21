//
//  BuiltInTransfromsTest.swift
//  CodableWrapperTest
//
//  Created by winddpan on 2020/8/21.
//

import CodableWrapper
import XCTest

// TODO: this file is not loaded, for Transform is not support yet
class BuiltInTransfromsTest: XCTestCase {
    func testDateTransfrom() throws {
        struct ExampleModel: Codable {
            @CodableWrapper(transformer: SecondsDateTransform())
            var sencondsDate: Date

            @CodableWrapper(transformer: MillisecondDateTransform())
            var millSecondsDate: Date
        }

        let date = Date()
        let json = """
        {"sencondsDate": \(date.timeIntervalSince1970), "millSecondsDate": \(date.timeIntervalSince1970 * 1000)}
        """

        let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.sencondsDate.timeIntervalSince1970, date.timeIntervalSince1970)
        XCTAssertEqual(model.millSecondsDate.timeIntervalSince1970, date.timeIntervalSince1970)
    }
    
    func testOmit() throws {
        struct ExampleModel: Codable {
            @CodableWrapper(transformer: OmitEncoding())
            var omitEncoding: String?

            @CodableWrapper(transformer: OmitDecoding())
            var omitDecoding: String?
        }
        
        let json = """
        {"omitEncoding": 123, "omitDecoding": "abc"}
        """
        let model = try JSONDecoder().decode(ExampleModel.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.omitEncoding, "123")
        XCTAssertEqual(model.omitDecoding, nil)

        let data = try JSONEncoder().encode(model)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        XCTAssertEqual(jsonObject["omitEncoding"] as? String, nil)
        XCTAssertEqual(jsonObject["omitDecoding"] as? String, nil)
    }
}
