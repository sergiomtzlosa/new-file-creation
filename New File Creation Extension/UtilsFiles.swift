//
//  UtilsFiles.swift
//  New File Creation
//
//  Created by sid on 27/02/2019.
//  Copyright © 2019 com.sergiomtzlosa.filecreation. All rights reserved.
//

import Foundation

class UtilsFiles {
    
    static func isDirectory(pathURL: NSURL) -> Bool {
        
        var isDirectory : ObjCBool = false
        let fileExistsAtPath : Bool  = Foundation.FileManager.default.fileExists(atPath: pathURL.path!, isDirectory: &isDirectory)
        
        if (fileExistsAtPath)
        {
            if isDirectory.boolValue
            {
                // It's a Directory.
                return true
            }
        }
        
        return false
    }
}
