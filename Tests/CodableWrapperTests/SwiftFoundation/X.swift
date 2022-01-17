//
//  X.swift
//  CodableWrapperTest
//
//  Created by PAN on 2022/1/11.
//

import Foundation

protocol _NSNumberCastingWithoutBridging {
  var _swiftValueOfOptimalType: Any { get }
}

extension NSNumber: _NSNumberCastingWithoutBridging {
    internal var _swiftValueOfOptimalType: Any {
        if self === kCFBooleanTrue {
            return true
        } else if self === kCFBooleanFalse {
            return false
        }
        
        fatalError()
        
//        let numberType = _CFNumberGetType2(_cfObject)
//        switch numberType {
//        case kCFNumberSInt8Type:
//            return Int(int8Value)
//        case kCFNumberSInt16Type:
//            return Int(int16Value)
//        case kCFNumberSInt32Type:
//            return Int(int32Value)
//        case kCFNumberSInt64Type:
//            return int64Value < Int.max ? Int(int64Value) : int64Value
//        case kCFNumberFloat32Type:
//            return floatValue
//        case kCFNumberFloat64Type:
//            return doubleValue
//        case kCFNumberSInt128Type:
//            // If the high portion is 0, return just the low portion as a UInt64, which reasonably fixes trying to roundtrip UInt.max and UInt64.max.
//            if int128Value.high == 0 {
//                return int128Value.low
//            } else {
//                return int128Value
//            }
//        default:
//            fatalError("unsupported CFNumberType: '\(numberType)'")
//        }
    }
}

public extension NSNumber {
    typealias CFType = CFNumber
    internal var _cfObject: CFType {
        return unsafeBitCast(self, to: CFType.self)
    }
    
    var _cfTypeID: CFTypeID {
        return CFNumberGetTypeID()
    }
}

extension NSDictionary {
    public typealias _StructType = Dictionary<AnyHashable,Any>
    
    public func _bridgeToSwift() -> _StructType {
        return _StructType._unconditionallyBridgeFromObjectiveC(self)
    }
}

extension NSArray  {
    public typealias _StructType = Array<Any>
    
    public func _bridgeToSwift() -> _StructType {
        return _StructType._unconditionallyBridgeFromObjectiveC(self)
    }
}


//extension NSDictionary: _StructTypeBridgeable {
//    public typealias _StructType = Dictionary<AnyHashable,Any>
//
//    public func _bridgeToSwift() -> _StructType {
//        return _StructType._unconditionallyBridgeFromObjectiveC(self)
//    }
//}
//
//extension NSArray : _StructTypeBridgeable {
//    public typealias _StructType = Array<Any>
//
//    public func _bridgeToSwift() -> _StructType {
//        return _StructType._unconditionallyBridgeFromObjectiveC(self)
//    }
//}
