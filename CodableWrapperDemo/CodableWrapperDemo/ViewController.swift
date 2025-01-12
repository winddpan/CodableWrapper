//
//  ViewController.swift
//  CodableWrapperDemo
//
//  Created by 陈钰 on 2024/4/1.
//

import CodableWrapper
import UIKit

class DataDecoder: JSONDecoder {
    private static let shared = DataDecoder()

    static func decode<T: Decodable, D>(data: D?) -> T? {
        return shared._decode(data: data)
    }

    func _decode<T: Decodable, D>(data: D?) -> T? {
        if let data = try? JSONSerialization.data(withJSONObject: data as Any) {
            do {
                return try decode(T.self, from: data)
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}

@Codable
class TestA {
    var name: String?
    var weight: Int = 70
}

@CodableSubclass
class TestB: TestA {
    var age: Int = 0
}

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let dic: [String: Any] = [
            "name": "aaa",
            "age": 18,
        ]
        if let model: TestB = DataDecoder.decode(data: dic) {
            print(model.name ?? "")
            print(model.age)
            print(model.weight)
        }
    }
}
