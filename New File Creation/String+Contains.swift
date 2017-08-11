//
//  String+Extension.swift
//  New File Creation
//
//  Created by sid on 08/08/15.
//  Copyright (c) 2015 com.sergiomtzlosa.filecreation. All rights reserved.
//

import Foundation

extension String
{
    func containsString(_ otherString : String) -> Bool
    {
        return self.range(of: otherString) != nil
    }
}
