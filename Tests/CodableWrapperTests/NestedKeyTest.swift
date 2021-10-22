//
//  NestedKeyTest.swift
//  CodableWrapperTest
//
//  Created by PAN on 2021/10/19.
//

import CodableWrapper
import XCTest

struct Role: Codable {
    @Codec("title")
    var show: String?

    @Codec("role.name")
    var name: String?

    @Codec("role.iq")
    var iq: Int = 0
}

class NestedKeyTest: XCTestCase {
    func testNested() throws {
        let rawJSON = """
        {
            "title": "The Big Bang Theory",
            "role": {
                "name": "Sheldon",
                "iq": 140
            }
        }
        """
        
        let model = try JSONDecoder().decode(Role.self, from: rawJSON.data(using: .utf8)!)
        XCTAssertEqual(model.show, "The Big Bang Theory")
        XCTAssertEqual(model.name, "Sheldon")
        XCTAssertEqual(model.iq, 140)

        let jsonData = try JSONEncoder().encode(model)
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
        let role = (jsonObject["role"] as? [String: Any])

        XCTAssertEqual(jsonObject["title"] as? String, "The Big Bang Theory")
        XCTAssertEqual(role?["name"] as? String, "Sheldon")
        XCTAssertEqual(role?["iq"] as? Int, 140)
    }
}
