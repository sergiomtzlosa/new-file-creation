//
//  SMLog.swift
//  Traffic
//
//  Created by sid on 25/08/14.
//  Copyright (c) 2014 Sergio Martinez-Losa. All rights reserved.
//

import Foundation

private class DLog
{
    class func logWithString(_ string: Any...,  isDebug: Bool)
    {
        if (isDebug)
        {
            print(string)
        }
    }
}

public func SMLog(_ string : Any...)
{
    #if DEVELOPMENT
        DLog.logWithString(string, isDebug: true)
    #else
        DLog.logWithString(string, isDebug: false)
    #endif
}
