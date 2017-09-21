//
//  SMAlert.swift
//  New File Creation
//
//  Created by sid on 04/08/15.
//  Copyright (c) 2015 com.sergiomtzlosa.filecreation. All rights reserved.
//

import Foundation
import Cocoa

class SMAlert: NSWindow, NSWindowDelegate
{
    var completionBlock : Completion?

//    required init?(coder: NSCoder)
//    {
//        super.init(coder: coder)
//    }
    
    class func createViewWithTitle(_ message : NSString) -> SMAlert
    {
        return SMAlert.createViewWithTitle(NSString(string: SMObject.applicationName()), message: message)
    }
    
    class func createViewWithTitle(_ title: NSString, message:NSString) -> SMAlert
    {
        let window : SMAlert = SMAlert()//SMAlert(coder: NSCoder())!
    
        let alert : NSView = NSView(frame: NSMakeRect(0, 0, 424, 140))
        window.setFrame(alert.frame, display: true)
    
        let icon : NSImage = NSApp.applicationIconImage
        icon.size = NSMakeSize(60, 60)
    
        let iconImage : NSImageView = NSImageView(frame: NSMakeRect(31, 30, 70, 83))
    
        iconImage.image = icon
    
        alert.addSubview(iconImage)
    
        let titleAttr : NSMutableAttributedString = NSMutableAttributedString(string: title as String)
    
        titleAttr.addAttribute(NSAttributedStringKey.font, value: NSFont.boldSystemFont(ofSize: 13), range: NSMakeRange(0, titleAttr.length))
    
        let titleText : NSTextField = NSTextField(frame: NSMakeRect(141, 77, 211, 26))
        
        titleText.attributedStringValue = titleAttr
        titleText.isEditable = false
        titleText.isSelectable = false
        titleText.drawsBackground = false
        titleText.isSelectable = false
        titleText.backgroundColor = NSColor.clear
        titleText.isBezeled = false
        
        alert.addSubview(titleText)
    
        let textAlert : NSTextView = NSTextView(frame: NSMakeRect(138, 39, 250, 39))
    
        textAlert.isEditable = false
        textAlert.isSelectable = false
        textAlert.drawsBackground = false
        textAlert.isSelectable = false
        textAlert.backgroundColor = NSColor.clear
    
        let msgAttr : NSMutableAttributedString = NSMutableAttributedString(string: message as String!)
    
        msgAttr.addAttribute(NSAttributedStringKey.font, value: NSFont.systemFont(ofSize: 11), range: NSMakeRange(0, msgAttr.length))
        
        textAlert.textStorage!.append(msgAttr)
    
        alert.addSubview(textAlert)
    
        let buttonDismiss : NSButton = NSButton(frame: NSMakeRect(316, 4, 94, 32))
    
        buttonDismiss.setButtonType(NSButton.ButtonType.momentaryPushIn)
        buttonDismiss.bezelStyle = NSButton.BezelStyle.rounded
        buttonDismiss.title = "OK"
        buttonDismiss.target = window
        buttonDismiss.action = #selector(SMAlert.dismissModalWindow(_:))
    
        alert.addSubview(buttonDismiss)
        window.contentView = alert
    
        window.completionBlock = nil
    
        return window
    }
    
    class func createViewWithTitle(_ titleText : NSString, messageText:NSString, block:@escaping Completion) -> SMAlert
    {
        let alert : SMAlert = SMAlert.createViewWithTitle(titleText, message: messageText)
        alert.completionBlock = block
    
        return alert
    }
    
    class func createViewWithTitle(_ titleText : NSString, messageText: NSString, window:NSWindow) -> SMAlert
    {
        let alert : SMAlert = SMAlert.createViewWithTitle(titleText, message: messageText)
        alert.showModalInWindow(window)
        
        return alert
    }
    
    class func createAlertViewWithTitle(_ titleText: NSString, messageText: NSString, window: NSWindow) -> NSAlert
    {
        let alert : NSAlert = NSAlert()
        alert.messageText = titleText as String
        alert.informativeText = messageText as String
        alert.addButton(withTitle: "OK")
        alert.runModal()
        
        return alert
    }
    
    func showModalInWindow(_ win : NSWindow)
    {
        NSApp.beginSheet(self, modalFor: win, modalDelegate: delegate, didEnd: nil, contextInfo: nil)
//        self.beginSheet(win, completionHandler: nil)
    }
    
    @objc func dismissModalWindow(_ sender : AnyObject)
    {
        NSApp.endSheet(self)
//        self.endSheet(self)
        
        self.orderOut(nil)
    
        if (completionBlock != nil)
        {
            completionBlock!()
        }
    }
    
    override var canBecomeKey: Bool
    {
        return true
    }
    
    func windowWillResize(_ window: NSWindow, to newSize: NSSize) -> NSSize
    {
        if (window.showsResizeIndicator)
        {
            return newSize //resize happens
        }
        else
        {
            return window.frame.size //no change
        }
    }
    
    func windowShouldZoom(_ window: NSWindow, toFrame newFrame: NSRect) -> Bool
    {
        //let the zoom happen iff showsResizeIndicator is YES
        return window.showsResizeIndicator
    }
}
