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
    @IBOutlet var sliderDocumentsToday: NSSlider!
    @IBOutlet var labelDocumentsToday: NSTextField!
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
        
//        let numberRows : NSNumber = Preferences.numberOfRowsInTodayExtension()
//        var docRows : Int = numberRows.intValue
//
//        if (docRows > 10) {
//
//            docRows = 10
//            _ = Preferences.setNumberOfRowsInTodayExtension(rows: docRows)
//        }
//
//        if (docRows < 5) {
//
//            docRows = 5
//            _ = Preferences.setNumberOfRowsInTodayExtension(rows: docRows)
//        }
//
//        labelDocumentsToday.font = NSFont(name: "Helvetica", size: 13)
//        labelDocumentsToday.textColor = NSColor.black
//        labelDocumentsToday.alignment = NSTextAlignment.center
//        labelDocumentsToday.lineBreakMode = NSParagraphStyle.LineBreakMode.byWordWrapping
//        labelDocumentsToday.usesSingleLineMode = false
//        labelDocumentsToday.stringValue = SMLocalizedString("labelDocsToday") + " " + String(docRows) + " " + SMLocalizedString("documents")
//
//        sliderDocumentsToday.intValue = Int32(docRows)
//        sliderDocumentsToday.target = self
//        sliderDocumentsToday.action = #selector(sliderDocChanged(_:))
        
        super.awakeFromNib()
    }
    
//    @objc func sliderDocChanged(_ sender: NSSlider) {
//
//        let docRows: Int = Int(sliderDocumentsToday.intValue)
//
//        labelDocumentsToday.stringValue = SMLocalizedString("labelDocsToday") + " " + String(docRows) + " " + SMLocalizedString("documents")
//
//        _ = Preferences.setNumberOfRowsInTodayExtension(rows: docRows)
//    }
    
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
}
