
//
//  GeneralPreferences.swift
//  New File Creation
//
//  Created by sid on 14/08/15.
//  Copyright (c) 2015 com.sergiomtzlosa.filecreation. All rights reserved.
//

import Foundation

class GeneralPreferencesViewController : NSViewController, MASPreferencesViewController
{
    @IBOutlet var cautionImage: NSImageView!
    @IBOutlet var playSoundButton: NSButton!
    @IBOutlet var openFileButton: NSButton!
    @IBOutlet var revealFinderButton: NSButton!
    @IBOutlet var systemPrefesLabel: NSTextField!
    @IBOutlet var doubleClickButton: NSButton!
    @IBOutlet var hidePopupButton: NSButton!
    @IBOutlet var openSystemPreferencesButton: NSButton!
    
    override func awakeFromNib() {
        
        openSystemPreferencesButton.title = SMLocalizedString("openSystemPreferences")
        
        cautionImage.image = NSImage(named: NSImageNameCaution)
        
        playSoundButton.title = SMLocalizedString("playSoundPreference")
        playSoundButton.state = Preferences.loadActiveSound() ? NSOnState : NSOffState
        
        openFileButton.title = SMLocalizedString("openWhenCreate")
        openFileButton.state = Preferences.loadOpenFileOnCreation() ? NSOnState : NSOffState
        
        revealFinderButton.title = SMLocalizedString("revealCreationFile")
        revealFinderButton.state = Preferences.loadRevealInFinder() ? NSOnState : NSOffState
        
        doubleClickButton.title = SMLocalizedString("enableDoubleClick")
        doubleClickButton.state = Preferences.loadDoubleClick() ? NSOnState : NSOffState
        
        hidePopupButton.title = SMLocalizedString("hidePopUp")
        hidePopupButton.state = Preferences.loadHidePopup() ? NSOnState : NSOffState
            
        systemPrefesLabel.font = NSFont(name: "Helvetica", size: 11)
        systemPrefesLabel.textColor = NSColor.black
        systemPrefesLabel.alignment = NSTextAlignment.left
        systemPrefesLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        systemPrefesLabel.usesSingleLineMode = false
    
        systemPrefesLabel.stringValue = SMLocalizedString("enableExtensionTip")
        
        super.awakeFromNib()
    }
    
    @IBAction func openSystemPreferencesAction(_ sender: AnyObject) {
        
        Utils.openExtensionPreferences()
    }
    
    @IBAction func doubleClickAction(_ sender: AnyObject) {
        
        let button : NSButton = sender as! NSButton
        
        _ = Preferences.activeDoubleClick(button.state == NSOffState ? false : true)
    }
    
    @IBAction func hidePopUpAction(_ sender: AnyObject) {
        
        let button : NSButton = sender as! NSButton
        
        _ = Preferences.activeHidePopup(button.state == NSOffState ? false : true)
    }
    
    @IBAction func revealFinderAction(_ sender: AnyObject) {
        
        let button : NSButton = sender as! NSButton
        
        _ = Preferences.useRevealInFinder(button.state == NSOffState ? false : true)
    }
    
    @IBAction func openFileAction(_ sender: AnyObject) {
        
        let button : NSButton = sender as! NSButton
        
        _ = Preferences.openFileOnCreation(button.state == NSOffState ? false : true)
    }
    
    @IBAction func playSoundAction(_ sender: AnyObject) {
        
        let button : NSButton = sender as! NSButton
        
        _ = Preferences.activeSound(button.state == NSOffState ? false : true)
    }
    
    override init?(nibName nibNameString: String?, bundle bundleItem: Bundle?)
    {
        super.init(nibName: nibNameString, bundle: bundleItem)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("NSCoding not supported")
    }
    
    // MARK: - MASPreferencesViewController
    
    override var identifier: String?
    {
        get {
            return SMLocalizedString("general")
        }
        
        set {
            super.identifier = newValue
        }
    }
    
    var toolbarItemImage: NSImage
    {
        return NSImage(named:NSImageNamePreferencesGeneral)!
    }
    
    var toolbarItemLabel: String
    {
        return SMLocalizedString("general")
    }
}
