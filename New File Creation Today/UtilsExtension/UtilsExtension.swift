//
//  UtilsExtension.swift
//  New File Creation Today
//
//  Created by sid on 27/10/2017.
//  Copyright © 2017 com.sergiomtzlosa.filecreation. All rights reserved.
//

import Foundation

class UtilsExtension {
    
    class func extractFilesExtension() -> NSArray
    {
        let items : NSMutableArray = NSMutableArray()
        SMLog("extractFiles antes de loadTemplatesTablePreferences" )
        
        let arrayItems : NSArray = NSArray(array: Preferences.loadTemplatesTablePreferences())
        SMLog("antes if arrayItems")
        if (arrayItems.count > 0)
        {
            SMLog("entras aqui en arrayItems")
            
            for item in arrayItems
            {
                SMLog("aqui llega 1")
                let dict : NSDictionary = item as! NSDictionary
                
                let value : Any? = dict.value(forKey: "active")
                let active: Bool = value as! Bool
                
                //let active : Int = dict.object(forKey: "active") as! Int
                
                if (active == true)
                {
                    //let enabled : Int = dict.value(forKey: "enableColumn") as! Int
                    
                    let value : Any? = dict.value(forKey: "enableColumn")
                    let enabled: Bool = value as! Bool
                    
                    if (enabled == true)
                    {
                        let file : String = dict.value(forKey: "templateColumn") as! String
                        items.add(file)
                    }
                }
            }
        }
        
        SMLog("aqui fin")
        
        let finalArray :NSArray = NSArray(array: items)
        return finalArray
    }
}
