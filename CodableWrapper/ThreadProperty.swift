//
//  ThreadProperty.swift
//  CodableWrapperDev
//
//  Created by winddpan on 2020/8/15.
//  Copyright © 2020 YR. All rights reserved.
//

import Foundation

private var lastCodableWrapperKey: Void?
private var lastTransformWrapperKey: Void?

extension Thread {
    var lastCodableWrapper: AnyObject? {
        set {
            objc_setAssociatedObject(self, &lastCodableWrapperKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return objc_getAssociatedObject(self, &lastCodableWrapperKey) as AnyObject
        }
    }
    
    var lastTransformWrapper: AnyObject? {
        set {
            objc_setAssociatedObject(self, &lastTransformWrapperKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            return objc_getAssociatedObject(self, &lastTransformWrapperKey) as AnyObject
        }
    }
}
