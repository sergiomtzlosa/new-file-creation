//
//  Preferences.swift
//  New File Creation
//
//  Created by sid on 07/08/15.
//  Copyright (c) 2015 com.sergiomtzlosa.filecreation. All rights reserved.
//

import Foundation
import AppKit

class Preferences : NSObject
{
    private static var __once: () = {
            let shared = UserDefaults(suiteName: kGroupPreference)!
        }()
    
    class func wantsLaunchAtLogin(_ launch : Bool) -> Bool
    {
        let defaults : UserDefaults = UserDefaults.standard
        
        defaults.set(launch, forKey: "loginFilesCreation")
        
        return defaults.synchronize()
    }
    
    class func isLaunchedAtLogin() -> Bool
    {
        return UserDefaults.standard.bool(forKey: "loginFilesCreation")
    }
    
    // MARK: - Application settings
    
    class func activeSound(_ active : Bool) -> Bool
    {
        let defaults : UserDefaults = UserDefaults.standard
        
        defaults.set(active, forKey: "activeSound")
        
        let status : Bool = defaults.synchronize()
        
        _ = Preferences.writePlistApplicationPreferences()
        
        return status
    }
    
    class func loadActiveSound() -> Bool
    {
        return UserDefaults.standard.bool(forKey: "activeSound")
    }

    class func activeDoubleClick(_ active : Bool) -> Bool
    {
        let defaults : UserDefaults = UserDefaults.standard
        
        defaults.set(active, forKey: "enableDoubleClick")
        
        let status : Bool = defaults.synchronize()
        
        _ = Preferences.writePlistApplicationPreferences()
        
        return status
    }
    
    class func loadDoubleClick() -> Bool
    {
        return UserDefaults.standard.bool(forKey: "enableDoubleClick")
    }
    
    class func activeHidePopup(_ active : Bool) -> Bool
    {
        let defaults : UserDefaults = UserDefaults.standard
        
        defaults.set(active, forKey: "enableHidePopup")
        
        let status : Bool = defaults.synchronize()
        
        _ = Preferences.writePlistApplicationPreferences()
        
        return status
    }
    
    class func loadHidePopup() -> Bool
    {
        return UserDefaults.standard.bool(forKey: "enableHidePopup")
    }
    
    class func useRevealInFinder(_ reveal : Bool) -> Bool
    {
        let defaults : UserDefaults = UserDefaults.standard
        
        defaults.set(reveal, forKey: "reavealInFinder")
        
        let status : Bool = defaults.synchronize()
        
        _ = Preferences.writePlistApplicationPreferences()
        
        return status
    }
    
    class func loadRevealInFinder() -> Bool
    {
        return UserDefaults.standard.bool(forKey: "reavealInFinder")
    }
    
    class func openFileOnCreation(_ openFile : Bool) -> Bool
    {
        let defaults : UserDefaults = UserDefaults.standard
        
        defaults.set(openFile, forKey: "openFileWhenCreated")
        
        let status : Bool = defaults.synchronize()
        
        _ = Preferences.writePlistApplicationPreferences()
        
        return status
    }
    
    class func loadOpenFileOnCreation() -> Bool
    {
        return UserDefaults.standard.bool(forKey: "openFileWhenCreated")
    }
    
    class func setFirstBoot(_ openFile : Bool) -> Bool
    {
        let defaults : UserDefaults = UserDefaults.standard
        
        defaults.set(openFile, forKey: "firstBootNewFileCreation")
        
        return defaults.synchronize()
    }
    
    class func loadFirstBoot() -> Bool
    {
        return UserDefaults.standard.bool(forKey: "firstBootNewFileCreation")
    }
    
    class func loadTemplatesTablePreferences() -> NSArray
    {
        SMLog("metodo loadTemplatesTablePreferences")
        
        let defaults : UserDefaults = UserDefaults.standard
        defaults.set(Preferences.readPlistTemplatePreferences(), forKey: "templatesTablePreferences")
        defaults.synchronize()
        
        let array : NSArray = UserDefaults.standard.object(forKey: "templatesTablePreferences") as! NSArray
        
        SMLog("metodo loadTemplatesTablePreference2")
        
        return array
    }
    
    class func setTemplatesTablePreferences(_ templates: NSMutableArray) -> Bool
    {
        let defaults : UserDefaults = UserDefaults.standard
        
        defaults.set(templates, forKey: "templatesTablePreferences")
        
        let defaultsStatus : Bool = defaults.synchronize()
        let status : Bool = Preferences.writePlistTemplatePreferences(templates)
        
        if (status)
        {
            SMLog("escrito" as AnyObject)
        }
        else
        {
            SMLog("escrito" as AnyObject)
        }
        
        return defaultsStatus
    }
    
    class func writePlistApplicationPreferences() -> Bool
    {
        let soundEnabled : Bool = Preferences.loadActiveSound()
        let revealOnCreation : Bool = Preferences.loadRevealInFinder()
        let openOncreation : Bool = Preferences.loadOpenFileOnCreation()
        let doubleClick : Bool = Preferences.loadDoubleClick()
        let hidePopup : Bool = Preferences.loadHidePopup()
        
        let applicationPrefs : NSMutableDictionary = NSMutableDictionary()
        applicationPrefs.setObject(soundEnabled ? 1 : 0, forKey: "soundEnabled" as NSCopying)
        applicationPrefs.setObject(revealOnCreation ? 1 : 0, forKey: "revealOnCreation" as NSCopying)
        applicationPrefs.setObject(openOncreation ? 1 : 0, forKey: "openOncreation" as NSCopying)
        applicationPrefs.setObject(doubleClick ? 1 : 0, forKey: "enableDoubleClick" as NSCopying)
        applicationPrefs.setObject(hidePopup ? 1 : 0, forKey: "enableHidePopup" as NSCopying)
        
        let fileManager : Foundation.FileManager = Foundation.FileManager()
        let plistPath : String = FileManager.applicationDirectory().appendingPathComponent("application_prefs.plist")
        
        if (!fileManager.fileExists(atPath: plistPath))
        {
            
            let bundle : String = Bundle.main.path(forResource: "application_prefs", ofType:"plist")!
            do {
                try fileManager.copyItem(atPath: bundle, toPath:plistPath)
            } catch let error1 as NSError {
                
                SMLog(error1.localizedDescription)
            }
        }
        
        return applicationPrefs.write(toFile: plistPath, atomically:true)
    }
    
    class func readPlistApplicationPreferences() -> NSMutableDictionary?
    {
        let plistPath : String = FileManager.applicationDirectory().appendingPathComponent("application_prefs.plist")
        
        let fileManager : Foundation.FileManager = Foundation.FileManager()
        
        if (!fileManager.fileExists(atPath: plistPath))
        {
            _ = writePlistApplicationPreferences()
        }
        
        let plistData : NSMutableDictionary = NSMutableDictionary(contentsOfFile: plistPath)!
        
        let finalDict : NSMutableDictionary? = NSMutableDictionary(dictionary: plistData)
    
        return finalDict
    }
    
    class func writePlistTemplatePreferences(_ prefs : NSArray) -> Bool
    {
        let fileManager : Foundation.FileManager = Foundation.FileManager()
        let plistPath : String = FileManager.applicationDirectory().appendingPathComponent("templates_prefs.plist")
        
        if (!fileManager.fileExists(atPath: plistPath))
        {
            //var error : NSError? = nil
            let bundle : String = Bundle.main.path(forResource: "templates_prefs", ofType:"plist")!
            
            do {
                try fileManager.copyItem(atPath: bundle, toPath:plistPath)
            } catch let error1 as NSError {
                
                SMLog(error1.localizedDescription)
            }
        }
        
        return prefs.write(toFile: plistPath, atomically:true)
    }
    
    class func readPlistTemplatePreferences() -> NSMutableArray
    {
        let plistPath : String = FileManager.applicationDirectory().appendingPathComponent("templates_prefs.plist")
        
        let fileManager : Foundation.FileManager = Foundation.FileManager()
        
        if (!fileManager.fileExists(atPath: plistPath))
        {
           setDefaultValues()
        }
        
        let plistData : NSArray = NSArray(contentsOfFile: plistPath)!
        
        let finalArray : NSMutableArray = NSMutableArray(array: plistData)
        
        return finalArray
    }
    
    class func sharedUserDefaults() -> UserDefaults {
        
        //var shared : NSUserDefaults?
        
        struct Static {
            static var onceToken: Int = 0
            static var shared : UserDefaults? = nil
        }
        
        _ = Preferences.__once
        
        return Static.shared!
    }
    
    class func setDefaultValues()
    {
        FileManager.removeApplicationDirectory()
        
        let array : NSMutableArray = NSMutableArray()
        
        for item in FileManager.listBundleTemplates()
        {
            let dict : NSMutableDictionary = NSMutableDictionary()
            
            dict.setObject(1, forKey: "enableColumn" as NSCopying)
            dict.setObject(1, forKey: "active" as NSCopying)
            dict.setObject(item, forKey: "templateColumn" as NSCopying)
            
            array.add(dict)
        }
        
        SMLog(array)
        
        let status : Bool = Preferences.setTemplatesTablePreferences(array)
        
        if status
        {
            SMLog("saved")
        }
        else
        {
            SMLog("not saved")
        }
    }
    
    class func defaultsContainsKey(_ key : String) -> Bool
    {
        let defaults : UserDefaults = UserDefaults.standard
        
        let dict : NSDictionary = defaults.dictionaryRepresentation() as NSDictionary
        let arrayKeys : NSArray = dict.allKeys as NSArray
        
        if (arrayKeys.contains(key))
        {
            SMLog("mykey found")
            return true
        }
        
        SMLog("mykey not found")
        return false
    }
    
    // MARK: -
    // MARK: NSTouchbar preferences
    class func setFadeTouchBarButtons(_  fadeTouchbar: Bool) -> Bool
    {
        let defaults : UserDefaults = UserDefaults.standard
        
        defaults.set(fadeTouchbar, forKey: "fadeTouchBar")
        
        return defaults.synchronize()
    }
    
    class func fadeTouchbar() -> Bool
    {
        let key = "fadeTouchBar"
        
        if (!isKeyPresentInUserDefaults(key: key))
        {
            return true
        }
        
        return UserDefaults.standard.bool(forKey: key)
    }
    
    class func setShowTitleTouchBarButtons(_  showTitle: Bool) -> Bool
    {
        let defaults : UserDefaults = UserDefaults.standard
        
        defaults.set(showTitle, forKey: "showTitleButtonsTouchBar")
        
        return defaults.synchronize()
    }
    
    class func showTitleTouchBarButtons() -> Bool
    {
        let key = "showTitleButtonsTouchBar"
        
        if (!isKeyPresentInUserDefaults(key: key))
        {
            return true
        }
        
        return UserDefaults.standard.bool(forKey: key)
    }
    
    class func setUpdateTouchBarButtons(_  showTitle: Bool) -> Bool
    {
        let defaults : UserDefaults = UserDefaults.standard
        
        defaults.set(showTitle, forKey: "updateButtonsTouchbar")
        
        return defaults.synchronize()
    }
    
    class func updateTouchBarButtons() -> Bool
    {
        let key = "updateButtonsTouchbar"
        
        if (!isKeyPresentInUserDefaults(key: key))
        {
            return true
        }
        
        return UserDefaults.standard.bool(forKey: key)
    }

    class func isKeyPresentInUserDefaults(key: String) -> Bool
    {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}
