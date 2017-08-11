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
    
    override init?(nibName nibNameString: String?, bundle bundleItem: Bundle?) {
        super.init(nibName: nibNameString, bundle: bundleItem)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func viewWillAppear() {
        
        textViewHelp.scrollRangeToVisible(NSMakeRange(0, 0))
        super.viewWillAppear()
    }
    
    override func awakeFromNib() {
        
        let path : String = Bundle.main.path(forResource: currentLanguage() == "es" ? "help_es" : "help", ofType: "rtfd")!
    
        textViewHelp.readRTFD(fromFile: path)

        textViewHelp.frame = NSMakeRect(0, 0, 588, textViewHelp.frame.size.height)
        textViewHelp.scrollRangeToVisible(NSMakeRange(0, 0))
        
        super.awakeFromNib()
    }
    
    // MARK: - MASPreferencesViewController
    
    override var identifier: String? {
        
        get {
            return SMLocalizedString("help")
        }
        
        set {
            super.identifier = newValue
        }
    }
    
    var toolbarItemImage: NSImage
    {
        return NSImage(named:NSImageNameInfo)!
    }
    
    var toolbarItemLabel: String
    {
        return SMLocalizedString("help")
    }
}
