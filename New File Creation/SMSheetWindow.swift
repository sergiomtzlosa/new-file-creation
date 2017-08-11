
//
//  SMSheetWindow.swift
//  New File Creation
//
//  Created by sid on 04/08/15.
//  Copyright (c) 2015 com.sergiomtzlosa.filecreation. All rights reserved.
//

import Foundation
import Cocoa

class SMSheetWindow: NSWindowController
{
    var uploading : Bool!

    @IBOutlet var labelLoading: NSTextField!
    @IBOutlet var indeterminateBar: NSProgressIndicator!
    
    override init(window: NSWindow!)
    {
        DispatchQueue.main.async(execute: {
        
            window?.makeKeyAndOrderFront(nil)
        })
        
        super.init(window: window)
    }
    
    required init?(coder: NSCoder)
    {
        self.labelLoading.backgroundColor = NSColor.clear
        self.labelLoading.textColor = NSColor.black
        self.labelLoading.font = NSFont.boldSystemFont(ofSize: 25)
        
        super.init(coder: coder);
    }
    
    override func windowDidLoad()
    {
        super.windowDidLoad()
    }

    func beginSheet(_ mainWindow: NSWindow)
    {
        NSApp.beginSheet(self.window!, modalFor: mainWindow, modalDelegate: self, didEnd:nil, contextInfo: nil)
        
//        self.window!.beginSheet(mainWindow) { (NSModalResponse) in
//            
//        }
//        self.window?.beginSheet(mainWindow, completionHandler: nil)

        DispatchQueue.main.async(execute: {
            
            self.labelLoading.backgroundColor = NSColor.clear
            self.labelLoading.textColor = NSColor.black
            self.labelLoading.font = NSFont.boldSystemFont(ofSize: 25)
            
            self.labelLoading.stringValue = (self.uploading == true) ? SMLocalizedString("uploading") : SMLocalizedString("downloading")
            self.indeterminateBar.usesThreadedAnimation = false
            self.indeterminateBar.startAnimation(nil)
            self.becomeFirstResponder()
            self.window?.makeKeyAndOrderFront(nil)
        })
    }
    
    @IBAction func btnClicked(_ sender: AnyObject)
    {
        self.endSheet();
    }

    func endSheet() {
        
        NSApp.endSheet(self.window!)
//        self.window?.endSheet(self.window!)
        
        self.window!.orderOut(nil)
    }
}
