//
//  Utils.swift
//  New File Creation
//
//  Created by sid on 12/08/15.
//  Copyright (c) 2015 com.sergiomtzlosa.filecreation. All rights reserved.
//

import Foundation
import AppKit

class Utils
{
    class func revealInFinder(_ path : String!)
    {
        NSWorkspace.shared().activateFileViewerSelecting([URL(fileURLWithPath: path)])
    }
    
    class func openFile(_ path : String)
    {
        NSWorkspace.shared().openFile(path)
    }
    
    class func openExtensionPreferences()
    {
        NSWorkspace.shared().open(URL(fileURLWithPath: "/System/Library/PreferencePanes/Extensions.prefPane"))
    }
    
    class func openCloudPreferences()
    {
        NSWorkspace.shared().open(URL(fileURLWithPath: "/System/Library/PreferencePanes/iCloudPref.prefPane"))
    }

    class func resize(image: NSImage, w: Int, h: Int) -> NSImage {
        
        let destSize = NSMakeSize(CGFloat(w), CGFloat(h))
        let newImage = NSImage(size: destSize)
        newImage.lockFocus()
        image.draw(in: NSMakeRect(0, 0, destSize.width, destSize.height), from: NSMakeRect(0, 0, image.size.width, image.size.height), operation: NSCompositingOperation.sourceOver, fraction: CGFloat(1))
        newImage.unlockFocus()
        newImage.size = destSize
        return NSImage(data: newImage.tiffRepresentation!)!
    }
}
