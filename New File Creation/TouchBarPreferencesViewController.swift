//
//  TouchBarPreferencesViewController.swift
//  New File Creation
//
//  Created by sid on 17/03/2017.
//  Copyright © 2017 com.sergiomtzlosa.filecreation. All rights reserved.
//

import Foundation

class TouchBarPreferencesViewController : NSViewController, MASPreferencesViewController
{
    @IBOutlet var fadeEffectOption: NSButton!
    @IBOutlet var extersionFileOption: NSButton!
//    @IBOutlet var syncTemplatesOption: NSButton!
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("NSCoding not supported")
    }
    
    override func awakeFromNib() {

        fadeEffectOption.title = SMLocalizedString("fadeButtonTitle")
        fadeEffectOption.state = Preferences.fadeTouchbar() ? NSOnState : NSOffState
        
        extersionFileOption.title = SMLocalizedString("textButtonTitle")
        extersionFileOption.state = Preferences.showTitleTouchBarButtons() ? NSOnState : NSOffState
        
//        syncTemplatesOption.title = SMLocalizedString("syncButtonTitle")
//        syncTemplatesOption.state = Preferences.updateTouchBarButtons() ? NSOnState : NSOffState
//        
//        syncTemplatesOption.hidden = true
        
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    override init?(nibName nibNameString: String?, bundle bundleItem: Bundle?) {
        
        super.init(nibName: nibNameString, bundle: bundleItem)
    }
    
    @IBAction func fadeEffectTouchBarAction(_ sender: AnyObject) {
        
        let button : NSButton = sender as! NSButton
        
        _ = Preferences.setFadeTouchBarButtons(button.state == NSOffState ? false : true)
        
        SCHEDULE_POSTNOTIFICATION(kUpdateTableFromPreferences, object: nil)
    }
    
    @IBAction func extensionFileTouchBarAction(_ sender: AnyObject) {
        
        let button : NSButton = sender as! NSButton
        
        _ = Preferences.setShowTitleTouchBarButtons(button.state == NSOffState ? false : true)
        
        SCHEDULE_POSTNOTIFICATION(kUpdateTableFromPreferences, object: nil)
    }
    
//    @IBAction func syncTemplateTouchBarAction(_ sender: AnyObject) {
//        
//        let button : NSButton = sender as! NSButton
//        
//        _ = Preferences.setUpdateTouchBarButtons(button.state == NSOffState ? false : true)
//        
//        SCHEDULE_POSTNOTIFICATION(kUpdateTableFromPreferences, object: nil)
//    }
    
    // MARK: - MASPreferencesViewController
    
    override var identifier: String?
    {
        get {
            return "touchbar-preferences"
        }
        
        set {
            super.identifier = newValue
        }
    }
    
    var toolbarItemImage: NSImage
    {
        return NSImage(named:NSImageNameMultipleDocuments)!
    }
    
    var toolbarItemLabel: String
    {
        return SMLocalizedString("touchbar")
    }
}
