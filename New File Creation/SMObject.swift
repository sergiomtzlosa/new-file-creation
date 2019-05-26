//
//  SMObject.swift
//  New File Creation
//
//  Created by sid on 04/08/15.
//  Copyright (c) 2015 com.sergiomtzlosa.filecreation. All rights reserved.
//

import Foundation
import Cocoa

typealias Completion = () -> ()

class SMObject: NSObject
{
    var windowObject : NSWindow?

    override init()
    {
        super.init()
    }
    
    override func awakeFromNib()
    {
//        windowObject!.center()
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
//        var edit : NSMenu = NSApplication.sharedApplication().mainMenu!.itemWithTitle("Edit")!.submenu!
//        
//        if (edit.itemAtIndex(edit.numberOfItems - 1)?.action == NSSelectorFromString("orderFrontCharacterPalette:"))
//        {
//            edit.removeItemAtIndex((edit.numberOfItems) - 1)
//        }
//        
//        if (edit.itemAtIndex((edit.numberOfItems) - 1)?.action == NSSelectorFromString("startDictation:"))
//        {
//            edit.removeItemAtIndex((edit.numberOfItems) - 1)
//        }
//        
//        if (edit.itemAtIndex((edit.numberOfItems) - 1)!.separatorItem)
//        {
//            edit.removeItemAtIndex((edit.numberOfItems) - 1)
//        }
    }
    
    class func sharedInstance() -> SMObject
    {
        return NSApplication.shared.delegate as! SMObject
    }
    
    class func applicationName() -> String
    {
        var dict : Dictionary? = (Bundle.main.infoDictionary as Dictionary?)
        return (dict!["CFBundleExecutable"] as? String)!
    }
    
    class func showModalAlert(_ title: String, message : String)
    {
        let alert = NSAlert()
        
        alert.messageText = title
        alert.addButton(withTitle: "OK")
        alert.informativeText = message
        
        alert.runModal()
    }
    
    class func showAlertWithMessage(_ message: NSString, completion: @escaping Completion) -> SMAlert?
    {
        let alert : SMAlert = SMAlert.createViewWithTitle(SMObject.applicationName() as NSString, messageText: message, block: completion)
    
        alert.showModalInWindow(SMObject.sharedInstance().windowObject!)
    
        return alert
    }
    
    class func showAlertWithMessage(_ message: NSString) -> SMAlert
    {
        let alert : SMAlert = SMAlert.createViewWithTitle(SMObject.applicationName() as NSString, message:message)
    
        alert.showModalInWindow(SMObject.sharedInstance().windowObject!)
    
        return alert
    }
    
    class func showAlertWithMessage(_ message: NSString, window : NSWindow) -> SMAlert
    {
        let alert : SMAlert = SMAlert.createViewWithTitle(SMObject.applicationName() as NSString, message:message)
        
        alert.showModalInWindow(window)
        
        return alert
    }
    
    func showSheet(_ sheetWindow: SMSheetWindow, win:NSWindow, delegate:AnyObject)
    {
//        NSApp.beginSheet(sheetWindow, modalForWindow: win, modalDelegate: delegate, didEndSelector: nil, contextInfo: nil)
        
        sheetWindow.window?.beginSheet(win, completionHandler: nil)
    }
    
    func hideSheet(_ sheetWindow: SMSheetWindow, win:NSWindow)
    {
 //       NSApp.endSheet(sheetWindow)
//        sheetWindow.orderOut(nil)
        
        sheetWindow.window?.endSheet(win)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ theApplication: NSApplication) -> Bool
    {
        return false
    }
    
    class func calculateSizeForText(_ text: NSString, textView: NSTextView) -> NSRect
    {
        // create the new font for the text field
        let newFont : NSFont = NSFont(name: "Helvetica", size: 20)!

        let maxWidth : CGFloat  = 200
        let maxHeight : CGFloat = 99999
        let constraint : CGSize  = CGSize(width: maxWidth, height: maxHeight)
        let attrs : NSDictionary = NSDictionary(object: newFont, forKey: NSAttributedString.Key.font as NSCopying)
        
//        let options : NSStringDrawingOptions = NSLineBreakMode.ByWordWrapping | NSStringDrawingOptions.UsesLineFragmentOrigin
        
        let options : NSString.DrawingOptions = NSString.DrawingOptions.usesLineFragmentOrigin
        
//        var newBounds : NSRect  = text.boundingRectWithSize(constraint, options: options, attributes: attrs as [NSObject : AnyObject])
        
        let newBounds : NSRect  = text.boundingRect(with: constraint, options: options, attributes: attrs as? [NSAttributedString.Key : AnyObject])
    
        return newBounds
    }
}
