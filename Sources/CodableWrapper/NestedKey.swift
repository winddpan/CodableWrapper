//
//  NestedKey.swift
//  CodableWrapper
//
//  Created by PAN on 2021/10/19.
//

import Foundation

class NestedKey {
    let key: String
    let paths: [String]

    init?(_ key: String) {
        let paths = key.components(separatedBy: ".").filter { !$0.isEmpty }
        if paths.count > 1 {
            self.key = key
            self.paths = paths
        } else {
            return nil
        }
    }

    func toDecodeResult(in dictionary: [String: Any]) -> Any? {
        var json: Any? = dictionary
        for path in paths {
            json = (json as? [String: Any])?[path]
        }
        return json
    }

    func replaceEncodeKey(in dictionary: NSMutableDictionary) {
        guard let rawValue = dictionary[key] else { return }
        var wrapper = dictionary
        for path in paths[0 ..< paths.count - 1] {
            do {
                wrapper = try wrapper.getOrCreateMutableDictionaryFor(key: path)
            } catch {
                dictionary.removeObject(forKey: paths[0])
                return
            }
        }
        dictionary.removeObject(forKey: key)
        wrapper.setValue(rawValue, forKey: paths[paths.count - 1])
    }
}

private extension NSMutableDictionary {
    func getOrCreateMutableDictionaryFor(key: String) throws -> NSMutableDictionary {
        let _old = object(forKey: key)
        if _old == nil {
            let new = NSMutableDictionary()
            setValue(new, forKey: key)
            return new
        } else if let old = _old as? NSMutableDictionary {
            return old
        } else {
            throw NSError(domain: "Key has been used, and is not NSMutableDictionary: \(key)", code: 0, userInfo: nil)
        }
    }
}
