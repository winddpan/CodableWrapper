//
//  SnakeCamelConvert.swift
//  CodableWrapper
//
//  Created by PAN on 2021/10/12.
//

import Foundation

extension String {
    private var isSnake: Bool {
        return self.contains("_")
    }

    private var firstCharUpperCased: String {
        if !self.isEmpty {
            var chars = Array(self)
            chars[0] = String.Element(chars[0].uppercased())
            return String(chars)
        }
        return self
    }

    private func snakeToCamel() -> String {
        var comps = self.components(separatedBy: "_").compactMap { $0.isEmpty ? nil : $0 }
        comps = comps.enumerated().map { idx, str in
            idx > 0 ? str.firstCharUpperCased : str
        }
        if self.first == "_" {
            comps.insert("_", at: 0)
        }
        if !comps.isEmpty, self.last == "_" {
            comps.append("_")
        }
        return comps.joined()
    }

    private func camelToSnake() -> String {
        var chars = Array(self)
        for (i, char) in chars.enumerated().reversed() {
            if char.isUppercase {
                chars[i] = String.Element(char.lowercased())
                if i > 0 {
                    chars.insert("_", at: i)
                }
            }
        }
        return String(chars)
    }

    func snakeCamelConvert() -> String? {
        let result: String
        if self.isSnake {
            result = self.snakeToCamel()
        } else {
            result = self.camelToSnake()
        }
        if self == result {
            return nil
        }
        return result
    }
}
