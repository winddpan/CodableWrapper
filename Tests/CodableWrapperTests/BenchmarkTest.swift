//
//  BenchmarkTest.swift
//  CodableWrapperTest
//
//  Created by PAN on 2021/8/3.
//

import CodableWrapper
import XCTest

@available(tvOS 13.0, *)
@available(iOS 13.0, *)
class BenchmarkTest: XCTestCase {
    var testData: Data!
    var metrics: [XCTMetric]!
    var measureOptions: XCTMeasureOptions!
    var array: [Any] = []

    override class func setUp() {}

    override func setUp() {
        testData = testJSON.data(using: .utf8)!
        metrics = [XCTMemoryMetric(), XCTClockMetric()]

        measureOptions = XCTMeasureOptions.default
        measureOptions.iterationCount = 5
    }

    func testModel10_Codec() throws {
        array = []
        measure(metrics: metrics, options: measureOptions) {
            for _ in 0...1000 {
                let model = try! JSONDecoder().decode(Model10_Codec.self, from: testData)
                XCTAssertEqual(model.val1, "d")
                array.append(model)
            }
        }
    }

    func testModel10_Native() throws {
        array = []
        measure(metrics: metrics, options: measureOptions) {
            for _ in 0...1000 {
                let model = try! JSONDecoder().decode(Model10_Native.self, from: testData)
                XCTAssertEqual(model.val1, "d")
                array.append(model)
            }
        }
    }

    func testModel60_Codec() throws {
        array = []
        measure(metrics: metrics, options: measureOptions) {
            for _ in 0...1000 {
                let model = try! JSONDecoder().decode(Model60_Codec.self, from: testData)
                XCTAssertEqual(model.val1, "d")
                array.append(model)
            }
        }
    }

    func testModel60_Native() throws {
        array = []
        measure(metrics: metrics, options: measureOptions) {
            for _ in 0...1000 {
                let model = try! JSONDecoder().decode(Model60_Native.self, from: testData)
                XCTAssertEqual(model.val1, "d")
                array.append(model)
            }
        }
    }
}

let testJSON = """
{"val1":"d","val2":17050,"val3":98150,"val4":83752,"val5":21042,"val6":50385,"val7":false,"val8":false,"val9":false,"val10":38296,"val11":41685,"val12":83313,"val13":true,"val14":29133,"val15":"c","val16":true,"val17":53560,"val18":"d","val19":true,"val20":26740,"val21":80319,"val22":96532,"val23":false,"val24":"f","val25":97530,"val26":"k","val27":"r","val28":23134,"val29":"t","val30":"t","val31":4622,"val32":"a","val33":"w","val34":false,"val35":"k","val36":27454,"val37":"j","val38":"e","val39":"q","val40":23289,"val41":true,"val42":96771,"val43":88066,"val44":"k","val45":94598,"val46":"u","val47":"k","val48":"l","val49":"n","val50":false}
"""

struct Model10_Codec: Codable {
    @Codec var val1: String = "b"
    @Codec var val2: Int = 17050
    @Codec var val3: Int = 98150
    @Codec var val4: Int = 83752
    @Codec var val5: Int = 21042
    @Codec var val6: Int = 50385
    @Codec var val7: Bool = false
    @Codec var val8: Bool = false
    @Codec var val9: Bool = false
    @Codec var val10: Int = 38296
}

struct Model60_Codec: Codable {
    @Codec var val1: String = "b"
    @Codec var val2: Int = 17050
    @Codec var val3: Int = 98150
    @Codec var val4: Int = 83752
    @Codec var val5: Int = 21042
    @Codec var val6: Int = 50385
    @Codec var val7: Bool = false
    @Codec var val8: Bool = false
    @Codec var val9: Bool = false
    @Codec var val10: Int = 38296
    @Codec var val11: Int = 41685
    @Codec var val12: Int = 83313
    @Codec var val13: Bool = true
    @Codec var val14: Int = 29133
    @Codec var val15: String = "c"
    @Codec var val16: Bool = true
    @Codec var val17: Int = 53560
    @Codec var val18: String = "d"
    @Codec var val19: Bool = true
    @Codec var val20: Int = 26740
    @Codec var val21: Int = 80319
    @Codec var val22: Int = 96532
    @Codec var val23: Bool = false
    @Codec var val24: String = "f"
    @Codec var val25: Int = 97530
    @Codec var val26: String = "k"
    @Codec var val27: String = "r"
    @Codec var val28: Int = 23134
    @Codec var val29: String = "t"
    @Codec var val30: String = "t"
    @Codec var val31: Int = 4622
    @Codec var val32: String = "a"
    @Codec var val33: String = "w"
    @Codec var val34: Bool = false
    @Codec var val35: String = "k"
    @Codec var val36: Int = 27454
    @Codec var val37: String = "j"
    @Codec var val38: String = "e"
    @Codec var val39: String = "q"
    @Codec var val40: Int = 23289
    @Codec var val41: Bool = true
    @Codec var val42: Int = 96771
    @Codec var val43: Int = 88066
    @Codec var val44: String = "k"
    @Codec var val45: Int = 94598
    @Codec var val46: String = "u"
    @Codec var val47: String = "k"
    @Codec var val48: String = "l"
    @Codec var val49: String = "n"
    @Codec var val50: Bool = false
    @Codec(transformer: SecondDateTransform()) var val51: Date?
    @Codec(transformer: SecondDateTransform()) var val52: Date?
    @Codec(transformer: SecondDateTransform()) var val53: Date?
    @Codec(transformer: SecondDateTransform()) var val54: Date?
    @Codec(transformer: SecondDateTransform()) var val55: Date?
    @Codec(transformer: SecondDateTransform()) var val56: Date?
    @Codec(transformer: SecondDateTransform()) var val57: Date?
    @Codec(transformer: SecondDateTransform()) var val58: Date?
    @Codec(transformer: SecondDateTransform()) var val59: Date?
    @Codec(transformer: SecondDateTransform()) var val60: Date?
}

struct Model10_Native: Codable {
    var val1: String = "b"
    var val2: Int = 17050
    var val3: Int = 98150
    var val4: Int = 83752
    var val5: Int = 21042
    var val6: Int = 50385
    var val7: Bool = false
    var val8: Bool = false
    var val9: Bool = false
    var val10: Int = 38296
}

struct Model10_2_Native: Codable {
    var val1: String
    var val2: Int
    var val3: Int
    var val4: Int
    var val5: Int
    var val6: Int
    var val7: Bool
    var val8: Bool
    var val9: Bool
    var val10: Int
}

struct Model60_Native: Codable {
    var val1: String = "b"
    var val2: Int = 17050
    var val3: Int = 98150
    var val4: Int = 83752
    var val5: Int = 21042
    var val6: Int = 50385
    var val7: Bool = false
    var val8: Bool = false
    var val9: Bool = false
    var val10: Int = 38296
    var val11: Int = 41685
    var val12: Int = 83313
    var val13: Bool = true
    var val14: Int = 29133
    var val15: String = "c"
    var val16: Bool = true
    var val17: Int = 53560
    var val18: String = "d"
    var val19: Bool = true
    var val20: Int = 26740
    var val21: Int = 80319
    var val22: Int = 96532
    var val23: Bool = false
    var val24: String = "f"
    var val25: Int = 97530
    var val26: String = "k"
    var val27: String = "r"
    var val28: Int = 23134
    var val29: String = "t"
    var val30: String = "t"
    var val31: Int = 4622
    var val32: String = "a"
    var val33: String = "w"
    var val34: Bool = false
    var val35: String = "k"
    var val36: Int = 27454
    var val37: String = "j"
    var val38: String = "e"
    var val39: String = "q"
    var val40: Int = 23289
    var val41: Bool = true
    var val42: Int = 96771
    var val43: Int = 88066
    var val44: String = "k"
    var val45: Int = 94598
    var val46: String = "u"
    var val47: String = "k"
    var val48: String = "l"
    var val49: String = "n"
    var val50: Bool = false
    var val51: Date?
    var val52: Date?
    var val53: Date?
    var val54: Date?
    var val55: Date?
    var val56: Date?
    var val57: Date?
    var val58: Date?
    var val59: Date?
    var val60: Date?
}
