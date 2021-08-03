//
//  DateTransform.swift
//  CodableWrapper
//
//  Created by PAN on 2020/8/21.
//

import Foundation

public struct SecondDateTransform: TransformType {
    public typealias Value = Date

    public var fromNull: (() -> Date)?
    public var fromJSON: ((Any?) -> Date)?
    public var toJSON: ((Date) -> Encodable?)?
    public let hashValue: Int

    public init(file: String = #file, line: Int = #line, column: Int = #column) {
        fromNull = {
            Date(timeIntervalSince1970: 0)
        }
        fromJSON = { json -> Date in
            if let timeInt = json as? Double {
                return Date(timeIntervalSince1970: TimeInterval(timeInt))
            }
            if let timeStr = json as? String {
                return Date(timeIntervalSince1970: TimeInterval(atof(timeStr)))
            }
            return Date(timeIntervalSince1970: 0)
        }
        toJSON = { object -> Encodable? in
            Double(object.timeIntervalSince1970)
        }
        hashValue = HasherChain()
            .combine(file)
            .combine(line)
            .combine(column)
            .hashValue
    }
}

public struct MillisecondDateTransform: TransformType {
    public typealias Value = Date

    public var fromNull: (() -> Date)?
    public var fromJSON: ((Any?) -> Date)?
    public var toJSON: ((Date) -> Encodable?)?
    public let hashValue: Int

    public init(file: String = #file, line: Int = #line, column: Int = #column) {
        fromNull = {
            Date(timeIntervalSince1970: 0)
        }
        fromJSON = { json -> Date in
            if let timeInt = json as? Double {
                return Date(timeIntervalSince1970: TimeInterval(timeInt / 1000))
            }
            if let timeStr = json as? String {
                return Date(timeIntervalSince1970: TimeInterval(atof(timeStr) / 1000))
            }
            return Date(timeIntervalSince1970: 0)
        }
        toJSON = { object -> Encodable? in
            Double(object.timeIntervalSince1970 * 1000)
        }
        hashValue = HasherChain()
            .combine(file)
            .combine(line)
            .combine(column)
            .hashValue
    }
}

open class DateFormatterTransform: TransformType {
    public typealias Value = Date

    public var fromNull: (() -> Date)?
    public var fromJSON: ((Any?) -> Date)?
    public var toJSON: ((Date) -> Encodable?)?

    public let dateFormatter: DateFormatter
    public var hashValue: Int

    public init(dateFormatter: DateFormatter, file: String = #file, line: Int = #line, column: Int = #column) {
        self.dateFormatter = dateFormatter

        fromNull = {
            Date(timeIntervalSince1970: 0)
        }
        fromJSON = { json -> Date in
            if let dateString = json as? String, let date = dateFormatter.date(from: dateString) {
                return date
            }
            return Date(timeIntervalSince1970: 0)
        }
        toJSON = { object -> Encodable? in
            dateFormatter.string(from: object)
        }
        hashValue = HasherChain()
            .combine(file)
            .combine(line)
            .combine(column)
            .hashValue
    }
}

public final class ISO8601DateTransform: DateFormatterTransform {
    public init(file: String = #file, line: Int = #line, column: Int = #column) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"

        super.init(dateFormatter: formatter)

        hashValue = HasherChain()
            .combine(formatter)
            .combine(file)
            .combine(line)
            .combine(column)
            .hashValue
    }
}
