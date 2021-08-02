//
//  DataModel.swift
//  CodableWrapperDemo
//
//  Created by PAN on 2021/8/2.
//

import Foundation
import CodableWrapper

struct DataModel: Codable {
    @Codec var intVal: Int = 1
}
