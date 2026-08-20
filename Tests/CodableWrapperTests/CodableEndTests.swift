import CodableWrapper
import Foundation
import XCTest

@Codable
private final class CodableEndModel {
    var value: Int = 0

    @CodingKeyIgnored
    var events: [String] = []

    @DecodeEnd
    func recordFirstDecodeEnd() {
        events.append("decode-1:\(value)")
    }

    @DecodeEnd
    func recordSecondDecodeEnd() throws {
        events.append("decode-2:\(value)")
    }

    @EncodeEnd
    func recordFirstEncodeEnd() {
        events.append("encode-1:\(value)")
        value += 1
    }

    @EncodeEnd
    func recordSecondEncodeEnd() throws {
        events.append("encode-2:\(value)")
    }
}

@Codable
private class CodableEndBaseModel {
    var baseValue: Int = 0

    @CodingKeyIgnored
    var events: [String] = []

    @DecodeEnd
    func recordBaseDecodeEnd() {
        events.append("base-decode")
    }

    @EncodeEnd
    func recordBaseEncodeEnd() {
        events.append("base-encode")
    }
}

@CodableSubclass
private final class CodableEndSubclassModel: CodableEndBaseModel {
    var subclassValue: Int = 0

    @DecodeEnd
    func recordSubclassDecodeEnd() {
        events.append("subclass-decode")
    }

    @EncodeEnd
    func recordSubclassEncodeEnd() {
        events.append("subclass-encode")
    }
}

final class CodableEndTests: XCTestCase {
    func testEndMethodsRunInDeclarationOrder() throws {
        let data = Data(#"{"value": 7}"#.utf8)
        let model = try JSONDecoder().decode(CodableEndModel.self, from: data)

        XCTAssertEqual(model.events, ["decode-1:7", "decode-2:7"])

        let encodedData = try JSONEncoder().encode(model)
        let encodedObject = try JSONSerialization.jsonObject(with: encodedData) as? [String: Int]

        XCTAssertEqual(encodedObject?["value"], 7)
        XCTAssertEqual(model.value, 8)
        XCTAssertEqual(model.events, ["decode-1:7", "decode-2:7", "encode-1:7", "encode-2:8"])
    }

    func testSubclassEndMethodsRunAfterSuperCalls() throws {
        let data = Data(#"{"baseValue": 1, "subclassValue": 2}"#.utf8)
        let model = try JSONDecoder().decode(CodableEndSubclassModel.self, from: data)

        XCTAssertEqual(model.events, ["base-decode", "subclass-decode"])

        _ = try JSONEncoder().encode(model)

        XCTAssertEqual(model.events, ["base-decode", "subclass-decode", "base-encode", "subclass-encode"])
    }
}
