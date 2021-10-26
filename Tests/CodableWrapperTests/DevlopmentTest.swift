//
//  DevlopmentTest.swift
//  CodableWrapperTest
//
//  Created by PAN on 2021/10/26.
//

import CodableWrapper
import XCTest

class A: Codable {
    @Codec var a: String = "aaa"
}

class B: A {
    @Codec var b: String = "bbb"
}

class C: B {
    @Codec var c: String = "ccc"
}

class DevlopmentTest: XCTestCase {
    func testSubclass() throws {
        let json = #"{"a": "success a", "b": 1, "c": "success c"}"#
        let model = try JSONDecoder().decodeInheritedClass(C.self, from: json.data(using: .utf8)!)
        XCTAssertEqual(model.a, "success a")
        XCTAssertEqual(model.b, "1")
        XCTAssertEqual(model.c, "success c")
        print(model)
    }
}
