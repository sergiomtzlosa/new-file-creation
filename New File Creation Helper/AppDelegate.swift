
//
//  AppDelegate.swift
//  New File Creation Helper
//
//  Created by sid on 04/08/15.
//  Copyright (c) 2015 com.sergiomtzlosa.filecreation. All rights reserved.
//

import Cocoa
import Foundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate
{
    @IBOutlet weak var window: NSWindow!

    func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        // Check if main app is already running, if yes, do nothing and terminate helper app
        var alreadyRunning : Bool = false
        let running : NSArray = NSWorkspace.shared().runningApplications as NSArray
        
        for app in running as! [NSRunningApplication]
        {
            let appIdentifier : NSString = app.bundleIdentifier! as NSString
            
            SMLog("appIdentifier: \(appIdentifier as String)")
            
            if (appIdentifier.isEqual(to: "com.sergiomtzlosa.filecreation"))
            {
                alreadyRunning = true
            }
        }
        
        if (!alreadyRunning)
        {
            let path : NSString = Bundle.main.bundlePath as NSString
            let p : NSArray = path.pathComponents as NSArray
            let pathComponents : NSMutableArray = NSMutableArray(array: p)
            
            pathComponents.removeLastObject()
            pathComponents.removeLastObject()
            pathComponents.removeLastObject()
            pathComponents.add("MacOS")
            pathComponents.add("New File Creation")
            
            let newPath : NSString = NSString.path(withComponents: pathComponents as NSArray as! [String]) as NSString
            
            SMLog("newPath: \(newPath as String)")
            
            NSWorkspace.shared().launchApplication(newPath as String)
        }
        
        NSApplication.shared().terminate(self)
    }
}

