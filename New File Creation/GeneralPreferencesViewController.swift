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
    
    var darkModeOn : Bool!
    
    override func awakeFromNib() {
        
        let appearance : String = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
        darkModeOn = (appearance.lowercased() == "dark") ? true : false
        
        REGISTER_DISTRIBUTED_NOTIFICATION(self, selector: #selector(GeneralPreferencesViewController.eventNotifyDarkModeChanged(_:)), name: kChangeInterfaceNotification)
        
        openSystemPreferencesButton.title = SMLocalizedString("openSystemPreferences")
        
        cautionImage.image = NSImage(named: NSImage.Name.caution)
        
        playSoundButton.title = SMLocalizedString("playSoundPreference")
        playSoundButton.state = Preferences.loadActiveSound() ? .on : .off
        
        openFileButton.title = SMLocalizedString("openWhenCreate")
        openFileButton.state = Preferences.loadOpenFileOnCreation() ? .on : .off
        
        revealFinderButton.title = SMLocalizedString("revealCreationFile")
        revealFinderButton.state = Preferences.loadRevealInFinder() ? .on : .off
        
        doubleClickButton.title = SMLocalizedString("enableDoubleClick")
        doubleClickButton.state = Preferences.loadDoubleClick() ? .on : .off
        
        hidePopupButton.title = SMLocalizedString("hidePopUp")
        hidePopupButton.state = Preferences.loadHidePopup() ? .on : .off
            
        systemPrefesLabel.font = NSFont(name: "Helvetica", size: 11)
        systemPrefesLabel.textColor = NSColor.black
        systemPrefesLabel.alignment = NSTextAlignment.left
        systemPrefesLabel.lineBreakMode = NSParagraphStyle.LineBreakMode.byWordWrapping
        systemPrefesLabel.usesSingleLineMode = false
    
        systemPrefesLabel.stringValue = SMLocalizedString("enableExtensionTip")
        
        systemPrefesLabel.attributedStringValue = createAttributeStringForButton(SMLocalizedString("enableExtensionTip"))
        
//        self.resignFirstResponder()
        super.awakeFromNib()
    }
    
    @IBAction func openSystemPreferencesAction(_ sender: AnyObject) {
        
        Utils.openExtensionPreferences()
    }
    
    @IBAction func doubleClickAction(_ sender: AnyObject) {
        
        let button : NSButton = sender as! NSButton
        
        _ = Preferences.activeDoubleClick(button.state == .off ? false : true)
    }
    
    @IBAction func hidePopUpAction(_ sender: AnyObject) {
        
        let button : NSButton = sender as! NSButton
        
        _ = Preferences.activeHidePopup(button.state == .off ? false : true)
    }
    
    @IBAction func revealFinderAction(_ sender: AnyObject) {
        
        let button : NSButton = sender as! NSButton
        
        _ = Preferences.useRevealInFinder(button.state == .off ? false : true)
    }
    
    @IBAction func openFileAction(_ sender: AnyObject) {
        
        let button : NSButton = sender as! NSButton
        
        _ = Preferences.openFileOnCreation(button.state == .off ? false : true)
    }
    
    @IBAction func playSoundAction(_ sender: AnyObject) {
        
        let button : NSButton = sender as! NSButton
        
        _ = Preferences.activeSound(button.state == .off ? false : true)
    }
    
    override init(nibName nibNameString: NSNib.Name?, bundle bundleItem: Bundle?)
    {
        super.init(nibName: nibNameString, bundle: bundleItem)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("NSCoding not supported")
    }
    
    // MARK: - MASPreferencesViewController
    
    override var identifier: NSUserInterfaceItemIdentifier?    {
        get {
            return NSUserInterfaceItemIdentifier(rawValue: SMLocalizedString("general"))
        }
        
        set {
            super.identifier = newValue
        }
    }
    
    var toolbarItemImage: NSImage
    {
        return NSImage(named:NSImage.Name.preferencesGeneral)!
    }
    
    var toolbarItemLabel: String
    {
        return SMLocalizedString("general")
    }
    
    override var acceptsFirstResponder: Bool
    {
        return false
    }
    
    @objc func eventNotifyDarkModeChanged(_ notification : Notification)
    {
        let appearance : String = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
        darkModeOn = (appearance.lowercased() == "dark") ? true : false
        
        systemPrefesLabel.attributedStringValue = createAttributeStringForButton(SMLocalizedString("enableExtensionTip"))
    }
    
    func createAttributeStringForButton(_ title : String) -> NSAttributedString
    {
        let color : NSColor = (darkModeOn!) ? NSColor.white : NSColor.black
        
        let attrTitle = NSMutableAttributedString(string: title)
        
        attrTitle.addAttribute(NSAttributedStringKey.font, value: NSFont(name: "Helvetica", size: 11.0)!, range: NSMakeRange(0, attrTitle.length))
        attrTitle.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: NSMakeRange(0, attrTitle.length))
        
        return attrTitle
    }
}
