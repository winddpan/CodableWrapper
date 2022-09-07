//
//  CodecOptionalProtocol.swift
//
//
//  Created by winddpan on 2022/8/2.
//

import Foundation

public protocol CodecOptionalProtocol {
    associatedtype Wrapped
}

extension Optional: CodecOptionalProtocol {}
