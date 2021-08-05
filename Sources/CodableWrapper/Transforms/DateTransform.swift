//
//  DateTransform.swift
//  CodableWrapper
//
//  Created by PAN on 2020/8/21.
//

import Foundation

public struct SecondDateTransform: TransformType {
    public typealias Object = Date
    public typealias JSON = TimeInterval

    public init() {}

    public func transformFromJSON(_ json: TimeInterval?) -> Date {
        if let timeInt = json {
            return Date(timeIntervalSince1970: TimeInterval(timeInt))
        }
        return Date(timeIntervalSince1970: 0)
    }

    public func transformToJSON(_ object: Date) -> TimeInterval? {
        TimeInterval(object.timeIntervalSince1970)
    }

    public func hashValue() -> Int {
        String(describing: Self.self).hashValue
    }
}

public struct MillisecondDateTransform: TransformType {
    public typealias Object = Date
    public typealias JSON = TimeInterval

    public init() {}

    public func transformFromJSON(_ json: TimeInterval?) -> Date {
        if let timeInt = json {
            return Date(timeIntervalSince1970: TimeInterval(timeInt / 1000))
        }
        return Date(timeIntervalSince1970: 0)
    }

    public func transformToJSON(_ object: Date) -> TimeInterval? {
        Double(object.timeIntervalSince1970 * 1000)
    }

    public func hashValue() -> Int {
        String(describing: Self.self).hashValue
    }
}

open class DateFormatterTransform: TransformType {
    public typealias Object = Date
    public typealias JSON = String

    public let dateFormatter: DateFormatter

    public func transformFromJSON(_ json: String?) -> Date {
        if let dateString = json, let date = dateFormatter.date(from: dateString) {
            return date
        }
        return Date(timeIntervalSince1970: 0)
    }

    public func transformToJSON(_ object: Date) -> String? {
        dateFormatter.string(from: object)
    }

    public func hashValue() -> Int {
        dateFormatter.hashValue
    }

    public init(dateFormatter: DateFormatter) {
        self.dateFormatter = dateFormatter
    }
}

public final class ISO8601DateTransform: DateFormatterTransform {
    public init() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        super.init(dateFormatter: formatter)
    }
}
