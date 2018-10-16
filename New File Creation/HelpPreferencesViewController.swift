//
//  HelpPreferencesViewController.swift
//  New File Creation
//
//  Created by sid on 14/08/15.
//  Copyright (c) 2015 com.sergiomtzlosa.filecreation. All rights reserved.
//

import Foundation

class HelpPreferencesViewController : NSViewController, MASPreferencesViewController
{
    @IBOutlet var textViewHelp: NSTextView!
    
    var darkModeOn : Bool!
    
    override init(nibName nibNameString: NSNib.Name?, bundle bundleItem: Bundle?) {
        
        super.init(nibName: nibNameString, bundle: bundleItem)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        fatalError("NSCoding not supported")
    }
    
    override func viewWillAppear() {
        
        textViewHelp.scrollRangeToVisible(NSMakeRange(0, 0))
        super.viewWillAppear()
    }
    
    override func awakeFromNib()
    {
        let appearance : String = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
        darkModeOn = (appearance.lowercased() == "dark") ? true : false
        
        REGISTER_DISTRIBUTED_NOTIFICATION(self, selector: #selector(GeneralPreferencesViewController.eventNotifyDarkModeChanged(_:)), name: kChangeInterfaceNotification)
        
        var fileHelpName : String = (currentLanguage() == "es" || currentLanguage() == "es-es")  ? "help_es" : "help"
        
        if darkModeOn
        {
            fileHelpName = fileHelpName + "_dark"
        }
     
        let path : String = Bundle.main.path(forResource: fileHelpName, ofType: "rtfd")!
        
        textViewHelp.readRTFD(fromFile: path)

        textViewHelp.frame = NSMakeRect(0, 0, 588, textViewHelp.frame.size.height)
        textViewHelp.scrollRangeToVisible(NSMakeRange(0, 0))
        
//        self.resignFirstResponder()
        super.awakeFromNib()
    }
    
    // MARK: - MASPreferencesViewController
    
    override var identifier: NSUserInterfaceItemIdentifier?
    {
        
        get {
            return NSUserInterfaceItemIdentifier(SMLocalizedString("help"))
        }
        
        set {
            super.identifier = newValue
        }
    }
    
    var toolbarItemImage: NSImage
    {
        return NSImage(named:NSImage.Name.info)!
    }
    
    var toolbarItemLabel: String
    {
        return SMLocalizedString("help")
    }
    
    @objc func eventNotifyDarkModeChanged(_ notification : Notification)
    {
        let appearance : String = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
        darkModeOn = (appearance.lowercased() == "dark") ? true : false
        
        var fileHelpName : String = (currentLanguage() == "es" || currentLanguage() == "es-es") ? "help_es" : "help"
       
        if darkModeOn
        {
            fileHelpName = fileHelpName + "_dark"
        }
        
        let path : String = Bundle.main.path(forResource: fileHelpName, ofType: "rtfd")!
        
        textViewHelp.readRTFD(fromFile: path)
    }
}
