//
//  DateTransform.swift
//  CodableWrapper
//
//  Created by PAN on 2020/8/21.
//

import Foundation

public struct SecondsDateTransform: TransformType {
    public let defaultDate: Date?

    public func fromNull() -> Date {
        return defaultDate ?? Date(timeIntervalSince1970: 0)
    }

    public func fromJSON(_ json: Any) -> TransformTypeResult<Date?> {
        if let timeInt = json as? Double {
            return .custom(Date(timeIntervalSince1970: TimeInterval(timeInt)))
        }

        if let timeStr = json as? String {
            return .custom(Date(timeIntervalSince1970: TimeInterval(atof(timeStr))))
        }
        return .custom(nil)
    }

    public func toJSON(_ object: Date) -> TransformTypeResult<Encodable?> {
        return .custom(Double(object.timeIntervalSince1970))
    }

    public init(defaultDate: Date? = nil) {
        self.defaultDate = defaultDate
    }
}

public struct MillisecondDateTransform: TransformType {
    public let defaultDate: Date?

    public func fromNull() -> Date {
        return defaultDate ?? Date(timeIntervalSince1970: 0)
    }

    public func fromJSON(_ json: Any) -> TransformTypeResult<Date?> {
        if let timeInt = json as? Double {
            return .custom(Date(timeIntervalSince1970: TimeInterval(timeInt / 1000)))
        }

        if let timeStr = json as? String {
            return .custom(Date(timeIntervalSince1970: TimeInterval(atof(timeStr) / 1000)))
        }
        return .custom(nil)
    }

    public func toJSON(_ object: Date) -> TransformTypeResult<Encodable?> {
        return .custom(Double(object.timeIntervalSince1970) * 1000)
    }

    public init(defaultDate: Date? = nil) {
        self.defaultDate = defaultDate
    }
}

open class DateFormatterTransform: TransformType {
    public let dateFormatter: DateFormatter

    public init(dateFormatter: DateFormatter) {
        self.dateFormatter = dateFormatter
    }

    public func fromNull() -> Date {
        return Date(timeIntervalSince1970: 0)
    }

    public func fromJSON(_ json: Any) -> TransformTypeResult<Date?> {
        if let dateString = json as? String {
            return .custom(dateFormatter.date(from: dateString))
        }
        return .custom(nil)
    }

    public func toJSON(_ object: Date) -> TransformTypeResult<Encodable?> {
        return .custom(dateFormatter.string(from: object))
    }
}

public class ISO8601DateTransform: DateFormatterTransform {
    public init() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        super.init(dateFormatter: formatter)
    }
}
