//
//  URL+Extension.swift
//  New File Creation
//
//  Created by sid on 27/02/2019.
//  Copyright © 2019 com.sergiomtzlosa.filecreation. All rights reserved.
//

import Foundation

extension URL {
    var isDirectory: Bool? {
        do {
            let values = try self.resourceValues(
                forKeys:Set([URLResourceKey.isDirectoryKey])
            )
            return values.isDirectory
        } catch  { return nil }
    }
}
