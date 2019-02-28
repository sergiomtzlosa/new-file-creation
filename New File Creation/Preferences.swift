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
    private static var __once: UserDefaults = {
        
        let shared : UserDefaults = UserDefaults(suiteName: kGroupPreference)!
        
        return shared
    }()
    
    class func wantsLaunchAtLogin(_ launch : Bool) -> Bool
    {
        let defaults : UserDefaults = Preferences.sharedUserDefaults()
        
        defaults.set(launch, forKey: "loginFilesCreation")
        
        return defaults.synchronize()
    }
    
    class func isLaunchedAtLogin() -> Bool
    {
        return Preferences.sharedUserDefaults().bool(forKey: "loginFilesCreation")
    }
    
    // MARK: - Application settings
    
    class func activeSound(_ active : Bool) -> Bool
    {
        let defaults : UserDefaults = Preferences.sharedUserDefaults()
        
        defaults.set(active, forKey: "activeSound")
        
        let status : Bool = defaults.synchronize()
        
        _ = Preferences.writePlistApplicationPreferences()
        
        return status
    }
    
    class func loadActiveSound() -> Bool
    {
        return Preferences.sharedUserDefaults().bool(forKey: "activeSound")
    }

    class func activeDoubleClick(_ active : Bool) -> Bool
    {
        let defaults : UserDefaults = Preferences.sharedUserDefaults()
        
        defaults.set(active, forKey: "enableDoubleClick")
        
        let status : Bool = defaults.synchronize()
        
        _ = Preferences.writePlistApplicationPreferences()
        
        return status
    }
    
    class func loadDoubleClick() -> Bool
    {
        return Preferences.sharedUserDefaults().bool(forKey: "enableDoubleClick")
    }
    
    class func activeHidePopup(_ active : Bool) -> Bool
    {
        let defaults : UserDefaults = Preferences.sharedUserDefaults()
        
        defaults.set(active, forKey: "enableHidePopup")
        
        let status : Bool = defaults.synchronize()
        
        _ = Preferences.writePlistApplicationPreferences()
        
        return status
    }
    
    class func loadHidePopup() -> Bool
    {
        return Preferences.sharedUserDefaults().bool(forKey: "enableHidePopup")
    }
    
    class func useRevealInFinder(_ reveal : Bool) -> Bool
    {
        let defaults : UserDefaults = Preferences.sharedUserDefaults()
        
        defaults.set(reveal, forKey: "reavealInFinder")
        
        let status : Bool = defaults.synchronize()
        
        _ = Preferences.writePlistApplicationPreferences()
        
        return status
    }
    
    class func loadRevealInFinder() -> Bool
    {
        return Preferences.sharedUserDefaults().bool(forKey: "reavealInFinder")
    }
    
    class func openFileOnCreation(_ openFile : Bool) -> Bool
    {
        let defaults : UserDefaults = Preferences.sharedUserDefaults()
        
        defaults.set(openFile, forKey: "openFileWhenCreated")
        
        let status : Bool = defaults.synchronize()
        
        _ = Preferences.writePlistApplicationPreferences()
        
        return status
    }
    
    class func loadOpenFileOnCreation() -> Bool
    {
        return Preferences.sharedUserDefaults().bool(forKey: "openFileWhenCreated")
    }
    
    class func setFirstBoot(_ openFile : Bool) -> Bool
    {
        let defaults : UserDefaults = Preferences.sharedUserDefaults()
        
        defaults.set(openFile, forKey: "firstBootNewFileCreation")
        
        return defaults.synchronize()
    }
    
    class func loadFirstBoot() -> Bool
    {
        return Preferences.sharedUserDefaults().bool(forKey: "firstBootNewFileCreation")
    }
    
    class func loadTemplatesTablePreferences() -> NSArray
    {
        SMLog("metodo loadTemplatesTablePreferences")
        
        let defaults : UserDefaults = Preferences.sharedUserDefaults()
        defaults.set(Preferences.readPlistTemplatePreferences(), forKey: "templatesTablePreferences")
        defaults.synchronize()
        
        let array : NSArray = Preferences.sharedUserDefaults().object(forKey: "templatesTablePreferences") as! NSArray
        
        SMLog("metodo loadTemplatesTablePreference2")
        
        return array
    }
    
    class func setTemplatesTablePreferences(_ templates: NSMutableArray) -> Bool
    {
        let defaults : UserDefaults = Preferences.sharedUserDefaults()
        
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

        return __once
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
        let defaults : UserDefaults = Preferences.sharedUserDefaults()
        
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
        let defaults : UserDefaults = Preferences.sharedUserDefaults()
        
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
        
        return Preferences.sharedUserDefaults().bool(forKey: key)
    }
    
    class func setShowTitleTouchBarButtons(_  showTitle: Bool) -> Bool
    {
        let defaults : UserDefaults = Preferences.sharedUserDefaults()
        
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
        
        return Preferences.sharedUserDefaults().bool(forKey: key)
    }
    
    class func setUpdateTouchBarButtons(_  showTitle: Bool) -> Bool
    {
        let defaults : UserDefaults = Preferences.sharedUserDefaults()
        
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
        
        return Preferences.sharedUserDefaults().bool(forKey: key)
    }

    class func isKeyPresentInUserDefaults(key: String) -> Bool
    {
        return Preferences.sharedUserDefaults().object(forKey: key) != nil
    }
    
    class func isKeyPresentInSharedUserDefaults(key: String) -> Bool
    {
        return Preferences.sharedUserDefaults().object(forKey: key) != nil
    }
    
    class func numberOfRowsInTodayExtension() -> NSNumber
    {
        let key = "rowsTodayExtension"
        
        if (!isKeyPresentInSharedUserDefaults(key: key)) {
            
            return NSNumber(value: 5)
        }

        return Preferences.sharedUserDefaults().object(forKey: key) as! NSNumber
    }
    
    class func setNumberOfRowsInTodayExtension(rows: Int) -> Bool
    {
        var itemsRow :Int = rows
        
        if (itemsRow < 5)
        {
            itemsRow = 5
        }
        
        if (itemsRow > 10)
        {
            itemsRow = 10
        }
        
        let defaults : UserDefaults = Preferences.sharedUserDefaults()
        
        defaults.set(NSNumber(value: itemsRow), forKey: "rowsTodayExtension")
        
        return defaults.synchronize()
    }
    
    class func setPopUpBehaviour(option: Int) -> Bool
    {
        let key = "pop-up-behaviour"
        
        let defaults : UserDefaults = Preferences.sharedUserDefaults()
        
        defaults.set(option, forKey: key)
        
        return defaults.synchronize()
    }
    
    class func popUpBehaviour() -> Int
    {
        let key = "pop-up-behaviour"
        
        if (!isKeyPresentInUserDefaults(key: key))
        {
            return 0
        }
        
        return Preferences.sharedUserDefaults().integer(forKey: key)
    }
    
    class func setSelectedFilesExtension(files: [String]) -> Bool
    {
        let key = "array-files-selection-finder"
        
        let defaults : UserDefaults = Preferences.sharedUserDefaults()
        
        defaults.set(files, forKey: key)
        
        return defaults.synchronize()
    }
    
    class func getSelectedFilesExtension() -> [String]
    {
        let key = "array-files-selection-finder"
        
        if (!isKeyPresentInUserDefaults(key: key))
        {
            return []
        }
        
        let loadedArray = Preferences.sharedUserDefaults().object(forKey: key) as? [String] ?? []
        
        return loadedArray
    }
}
