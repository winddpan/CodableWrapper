////
////  DevlopmentTest.swift
////  CodableWrapperTest
////
////  Created by PAN on 2021/10/26.
////
//
//import CodableWrapper
//import XCTest
//
//class InheritedClassTest: XCTestCase {
//    func testBasicInherited() throws {
//        class A: LosslessCodable {
//            @Codec var a: String = "aaa"
//            required init() {}
//        }
//
//        class B: A {
//            @Codec var b: String = "bbb"
//        }
//
//        class C: B {
//            @Codec var c: String = "ccc"
//        }
//
//        let json = #"{"a": "success a", "b": 888, "c": "success c"}"#
//        let model = try JSONDecoder().decode(C.self, from: json.data(using: .utf8)!)
//        XCTAssertEqual(model.a, "success a")
//        XCTAssertEqual(model.b, "888")
//        XCTAssertEqual(model.c, "success c")
//
//        let encoded = try JSONEncoder().encode(model)
//        let jsonObject = try JSONSerialization.jsonObject(with: encoded, options: []) as! [String: Any]
//        XCTAssertEqual(jsonObject["a"] as? String, "success a")
//        XCTAssertEqual(jsonObject["b"] as? String, "888")
//        XCTAssertEqual(jsonObject["c"] as? String, "success c")
//    }
//
//    func testComplexInherted() throws {
//        class A: LosslessCodable {
//            @Codec var a: String = "aaa"
//            required init() {}
//        }
//
//        class B: A {
//            @Codec var b: String = "bbb"
//        }
//
//        class C: B {
//            @Codec var c: String = "ccc"
//        }
//
//        struct W: Codable {
//            @Codec var i: Int = 123
//            @Codec var object = C()
//        }
//
//        let json = #"{"i": 999, "object": {"a": "success a", "b": 888, "c": "success c"}}"#
//        let model = try JSONDecoder().decode(W.self, from: json.data(using: .utf8)!)
//        XCTAssertEqual(model.object.a, "success a")
//        XCTAssertEqual(model.object.b, "888")
//        XCTAssertEqual(model.object.c, "success c")
//        
//        let encoded = try JSONEncoder().encode(model)
//        let root = try JSONSerialization.jsonObject(with: encoded, options: []) as! [String: Any]
//        XCTAssertEqual(root["i"] as? Int, 999)
//
//        let jsonObject = root["object"] as! [String: Any]
//        XCTAssertEqual(jsonObject["a"] as? String, "success a")
//        XCTAssertEqual(jsonObject["b"] as? String, "888")
//        XCTAssertEqual(jsonObject["c"] as? String, "success c")
//    }
//}
