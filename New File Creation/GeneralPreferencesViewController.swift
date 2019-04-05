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
    
    @IBOutlet var transientOption: NSButton!
    @IBOutlet var semitransientOption: NSButton!
    @IBOutlet var applicationDefinedOption: NSButton!
    @IBOutlet var labelRadioPopUp: NSTextField!
    
    var darkModeOn : Bool!
    
    override func awakeFromNib() {
        
        labelRadioPopUp.stringValue = SMLocalizedString("popup_behaviour")
        
        transientOption.title = SMLocalizedString("transient")
        transientOption.tag = SMPopUpState.transient.rawValue
        
        semitransientOption.title = SMLocalizedString("semitransient")
        semitransientOption.tag = SMPopUpState.semiTransient.rawValue
        
        applicationDefinedOption.title = SMLocalizedString("application_defined")
        applicationDefinedOption.tag = SMPopUpState.applicationDefined.rawValue
        
        transientOption.state = .off
        semitransientOption.state = .off
        applicationDefinedOption.state = .off
        
        let option : Int = Preferences.popUpBehaviour()
        
        if (option == SMPopUpState.transient.rawValue)
        {
            transientOption.state = .on
        }
        
        if (option == SMPopUpState.semiTransient.rawValue)
        {
            semitransientOption.state = .on
        }
        
        if (option == SMPopUpState.applicationDefined.rawValue)
        {
            applicationDefinedOption.state = .on
        }

        darkModeOn = isDarkModeEnabled()
        
        REGISTER_DISTRIBUTED_NOTIFICATION(self, selector: #selector(GeneralPreferencesViewController.eventNotifyDarkModeChanged(_:)), name: kChangeInterfaceNotification)
        
        openSystemPreferencesButton.title = SMLocalizedString("openSystemPreferences")
        
        cautionImage.image = NSImage(named: NSImage.cautionName)
        
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
        systemPrefesLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
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
        return NSImage(named:NSImage.preferencesGeneralName)!
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
        darkModeOn = isDarkModeEnabled()
        
        systemPrefesLabel.attributedStringValue = createAttributeStringForButton(SMLocalizedString("enableExtensionTip"))
    }
    
    @IBAction func popOverSelection(_ sender: AnyObject) {
        
        let buttonOption : NSButton = sender as! NSButton
        
        let option : Int = buttonOption.tag
        
        _ = Preferences.setPopUpBehaviour(option: option)
        
        buttonOption.state = .off
        transientOption.state = .off
        semitransientOption.state = .off
        applicationDefinedOption.state = .off
        
        if (option == SMPopUpState.transient.rawValue)
        {
            transientOption.state = .on
        }
        
        if (option == SMPopUpState.semiTransient.rawValue)
        {
            semitransientOption.state = .on
        }
        
        if (option == SMPopUpState.applicationDefined.rawValue)
        {
            applicationDefinedOption.state = .on
        }
    }
    
    func createAttributeStringForButton(_ title : String) -> NSAttributedString
    {
        let color : NSColor = (darkModeOn!) ? NSColor.white : NSColor.black
        
        let attrTitle = NSMutableAttributedString(string: title)
        
        attrTitle.addAttribute(NSAttributedString.Key.font, value: NSFont(name: "Helvetica", size: 11.0)!, range: NSMakeRange(0, attrTitle.length))
        attrTitle.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSMakeRange(0, attrTitle.length))
        
        return attrTitle
    }
}
