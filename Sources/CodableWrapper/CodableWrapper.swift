//
//  CodableWrapper.swift
//  CodableWrapper
//
//  Created by winddpan on 2020/8/15.
//

import Foundation

@propertyWrapper
public final class CodableWrapper<Value>: Codable {
    typealias DecoderInjection = (_ target: CodableWrapper<Value>, _ customKeys: [String]) -> Void
    
    struct Construct {
        var codingKeys: [String]
        var fromNull: () -> Value
        var fromJSON: (Any) -> TransformTypeResult<Value?>
        var toJSON: (Value) -> TransformTypeResult<Encodable?>
    }

    var construct: Construct?
    var decoderInjection: DecoderInjection?
    fileprivate var storedValue: Value?
    
    public var wrappedValue: Value {
        get { storedValue ?? construct!.fromNull() }
        set { storedValue = newValue }
    }

    deinit {
        if let construct = construct, let lastWrapper = Thread.current.lastCodableWrapper as? CodableWrapper<Value> {
            lastWrapper.invokeAfterInjection(with: construct)
            Thread.current.lastCodableWrapper = nil
        }
    }

    @available(*, unavailable, message: "directly `@CodableWrapper` only support optional value")
    public init() {
        fatalError()
    }

    init(construct: Construct) {
        self.construct = construct
    }
    
    public required init(from decoder: Decoder) throws {}
    
    init(unsafed: ()) {}

    private func invokeAfterInjection(with construct: Construct) {
        self.construct = construct
        decoderInjection?(self, construct.codingKeys)
        decoderInjection = nil
    }

    // Do nothing, KeyedEncodingContainer extension has done dirty stuff
    public func encode(to encoder: Encoder) throws {}
}
