//
//  NSUserDefaults+Extension.swift
//  New File Creation
//
//  Created by sid on 07/08/15.
//  Copyright (c) 2015 com.sergiomtzlosa.filecreation. All rights reserved.
//

import Foundation

extension UserDefaults
{
    class func keyExists(_ key : Bool) -> Bool
    {
        let dict : NSDictionary = UserDefaults.standard.dictionaryRepresentation() as NSDictionary
        
        return (dict.allKeys as NSArray).contains(key)
    }
}
