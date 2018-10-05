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
        fadeEffectOption.state = Preferences.fadeTouchbar() ? .on : .off
        
        extersionFileOption.title = SMLocalizedString("textButtonTitle")
        extersionFileOption.state = Preferences.showTitleTouchBarButtons() ? .on : .off
        
//        syncTemplatesOption.title = SMLocalizedString("syncButtonTitle")
//        syncTemplatesOption.state = Preferences.updateTouchBarButtons() ? NSOnState : NSOffState
//        
//        syncTemplatesOption.hidden = true
        
//        self.resignFirstResponder()
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    }
    
    override init(nibName nibNameString: NSNib.Name?, bundle bundleItem: Bundle?) {
        
        super.init(nibName: nibNameString, bundle: bundleItem)
    }
    
    @IBAction func fadeEffectTouchBarAction(_ sender: AnyObject) {
        
        let button : NSButton = sender as! NSButton
        
        _ = Preferences.setFadeTouchBarButtons(button.state == .off ? false : true)
        
        SCHEDULE_POSTNOTIFICATION(kUpdateTableFromPreferences, object: nil)
    }
    
    @IBAction func extensionFileTouchBarAction(_ sender: AnyObject) {
        
        let button : NSButton = sender as! NSButton
        
        _ = Preferences.setShowTitleTouchBarButtons(button.state == .off ? false : true)
        
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
    
    override var identifier: NSUserInterfaceItemIdentifier?
    {
        get {
            return NSUserInterfaceItemIdentifier("touchbar-preferences")
        }
        
        set {
            super.identifier = newValue
        }
    }
    
    var toolbarItemImage: NSImage
    {
        return NSImage(named:NSImage.Name.multipleDocuments)!
    }
    
    var toolbarItemLabel: String
    {
        return SMLocalizedString("touchbar")
    }
}
