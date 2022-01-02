//
//  SMMenu.swift
//  New File Creation Extension
//
//  Created by sid on 2/1/22.
//  Copyright © 2022 com.sergiomtzlosa.filecreation. All rights reserved.
//

import Foundation
import Cocoa

let MY_MENU_SEPARATOR = "---"

class SMMenu: NSMenu {
    
    override func addItem(withTitle string: String, action selector: Selector?, keyEquivalent charCode: String) -> NSMenuItem {
        
        if string == MY_MENU_SEPARATOR {
            
            let separator: NSMenuItem = NSMenuItem.separator()
            self.addItem(separator)
            return separator;
        }
        
        return super.addItem(withTitle: string, action: selector, keyEquivalent: charCode)
    }
    
    override func insertItem(withTitle string: String, action selector: Selector?, keyEquivalent charCode: String, at index: Int) -> NSMenuItem {
        
        if string == MY_MENU_SEPARATOR {
            
            let separator: NSMenuItem = NSMenuItem.separator()
            self.insertItem(separator, at: index)
            return separator;
        }
        
        return super.insertItem(withTitle: string, action: selector, keyEquivalent: charCode, at: index)
    }
}
