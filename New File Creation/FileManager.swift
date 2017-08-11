//
//  FileManager.swift
//  New File Creation
//
//  Created by sid on 08/08/15.
//  Copyright (c) 2015 com.sergiomtzlosa.filecreation. All rights reserved.
//

import Foundation
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class FileManager: NSObject {
    
    class func listBundleTemplates() -> NSArray
    {
        let path : String = FileManager.templatesPath()

        let tuple : (filenames: [String]?, error: NSError?) = contentsOfDirectoryAtPath(path)
        
        return tuple.filenames! as NSArray
    }
    
    class func listTemplates() -> NSArray
    {
        let path : String = FileManager.templatesPath()
        let applicationSupportPath = FileManager.applicationDirectory() as String
        
        let tuple : (filenames: [String]?, error: NSError?) = contentsOfDirectoryAtPath(path)
        let tupleSupport : (filenames: [String]?, error: NSError?) = contentsOfDirectoryAtPath(applicationSupportPath)
        
        let itemsFinal : NSMutableArray = NSMutableArray()
        
        if (tuple.filenames?.count > 0)
        {
            itemsFinal.addObjects(from: tuple.filenames!)
        }
        
        if (tupleSupport.filenames?.count > 0)
        {
            itemsFinal.addObjects(from: tupleSupport.filenames!)
        }
        
        let items : NSArray = NSArray(array: itemsFinal)
        
        return items
    }
    
    class func listExternalTemplates() -> NSArray
    {
        let applicationSupportPath = FileManager.applicationDirectory() as String
        let tupleSupport : (filenames: [String]?, error: NSError?) = contentsOfDirectoryAtPath(applicationSupportPath)
        
        let itemsFinal : NSMutableArray = NSMutableArray()
        
        if (tupleSupport.filenames?.count > 0)
        {
            itemsFinal.addObjects(from: tupleSupport.filenames!)
        }
        
        let items : NSArray = NSArray(array: itemsFinal)
        
        return items
    }
    
    class func templatesPath() -> String
    {
        var path : String = Bundle.main.resourcePath!
        path = path + "/Templates"
        
        SMLog("bundle " + path)
        return path
    }
    
    class func newExistingFile(with file: String, path: String) -> String
    {
        let tuple : (filenames: [String]?, error: NSError?) = FileManager.contentsOfDirectoryAtPath(path)
        
        let extensionFile : String = file.components(separatedBy: ".")[1]
        let files : [String] = tuple.filenames!
        
        let existenceFiles : NSMutableArray = NSMutableArray()
        
        for file in files
        {
            if file.containsString(extensionFile)
            {
                existenceFiles.add(file)
            }
        }

        if (existenceFiles.count > 1)
        {
            existenceFiles.remove(file)
        }
        
        let array : [String] = NSArray(array: existenceFiles) as! [String]
        
        let sortedArray : Array = array.sorted {
            
            return $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedDescending
        }
        
        SMLog(sortedArray)
        
        let lastFile : String = sortedArray[0] 
        let tempLastFile = URL(fileURLWithPath: lastFile)
        
        SMLog(lastFile)
        
        let fileName: String = (tempLastFile.deletingPathExtension().lastPathComponent)
        
        SMLog(fileName)
        
        var finalPath : String
        
        if fileName.containsString("-")
        {
            var split : [String] = fileName.components(separatedBy: "-") as [String]
            
            let baseName : String = split[0]
            var number : Int = Int(split[1])!
            
            number += 1
            
            let tempURL : URL = URL(fileURLWithPath: path)
            
            finalPath = tempURL.appendingPathComponent(baseName + "-" + String(number) + "." + tempLastFile.pathExtension).path
            
//           finalPath = tempURL.path
//            finalPath = path.stringByAppendingPathComponent(baseName + "-" + String(number) + "." + lastFile.pathExtension)
            
            SMLog("finalPath: \(finalPath)")
        }
        else
        {
            let tempURL : URL = URL(fileURLWithPath: path)
            
            SMLog("tempURL \(tempURL)")
            
            finalPath = (tempURL.appendingPathComponent(fileName + "-1." + tempLastFile.pathExtension)).path
        }
       
        SMLog("finalPath \(finalPath)")
        
        return finalPath
    }
    
    class func copyFile(from source: String, destination: inout String, file: String) -> Bool
    {
        if (Foundation.FileManager.default.fileExists(atPath: destination))
        {
            var plainDestPath : URL = URL(fileURLWithPath: destination)
            plainDestPath = plainDestPath.deletingLastPathComponent()
            
            destination = FileManager.newExistingFile(with: file, path: plainDestPath.path)
        }
        
        var status : Bool = false
        
        var error : NSError?
        
        SMLog("source: " + source)
        SMLog("destination: " + destination)
        do {
            try Foundation.FileManager.default.copyItem(atPath: source, toPath: destination)
            status = true
            SMLog("copied")
        } catch let error1 as NSError {
            error = error1
            SMLog("error: " + error!.localizedDescription)
        }
        
        return status
    }
    
    fileprivate class func contentsOfDirectoryAtPath(_ path: String) -> (filenames: [String]?, error: NSError?)
    {
        var error: NSError? = nil
        let fileManager = Foundation.FileManager.default
        let contents: [AnyObject]?
        do {
            contents = try fileManager.contentsOfDirectory(atPath: path) as [AnyObject]?
        } catch let error1 as NSError {
            error = error1
            contents = nil
        }
        
        if contents == nil
        {
            return (nil, error)
        }
        else
        {
            //var filenames = contents as! [String]
            
            var finalContent : [String] = []
            
            for item in contents as! [String]
            {
                if (!item.containsString(".plist"))
                {
                    finalContent.append(item)
                }
            }
            
            return (finalContent, nil)
        }
    }
    
    class func applicationDirectory() -> NSString
    {
//        var fileManager : NSFileManager = NSFileManager()
//        var bundleID : String = NSBundle.mainBundle().bundleIdentifier!
//        var urlPaths : NSArray = fileManager.URLsForDirectory(NSSearchPathDirectory.DocumentDirectory, inDomains:NSSearchPathDomainMask.UserDomainMask)
//     
//        SMLog(urlPaths)
//        
//        var appDirectory : NSURL = urlPaths.objectAtIndex(0).URLByAppendingPathComponent(bundleID, isDirectory:true)
//
//        SMLog("appDirectory.path: " + appDirectory.path!)
//        
//        if !fileManager.fileExistsAtPath(appDirectory.path!)
//        {
//            fileManager.createDirectoryAtURL(appDirectory, withIntermediateDirectories:false, attributes:nil, error:nil)
//        }
        
        let fileManager : Foundation.FileManager = Foundation.FileManager()
        let containerURL : URL = Foundation.FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: kGroupPreference)!
        
        let appDirectory : URL = containerURL.appendingPathComponent("NewFileCreation", isDirectory:true)

        if !fileManager.fileExists(atPath: appDirectory.path)
        {
            do {
                try fileManager.createDirectory(at: appDirectory, withIntermediateDirectories:false, attributes:nil)
            } catch _ {
            }
        }
        
        SMLog("appDirectory.path: " + appDirectory.path)

        return appDirectory.path as NSString
    }
 
    class func removeApplicationDirectory()
    {
        let fileManager : Foundation.FileManager = Foundation.FileManager()
        let directory : String = FileManager.applicationDirectory() as String
        
        //var error : NSError?
        
        let files : [String] = (try! fileManager.contentsOfDirectory(atPath: directory)) 
        
        for file in files
        {
            SMLog(file)
            
            if (!file.containsString("application_prefs"))
            {
                let tempURL : URL = URL(fileURLWithPath: directory).appendingPathComponent(file)
                let success : Bool = FileManager.removeFolderAtPath(tempURL)
                
                if (!success)
                {
                    SMLog("not deleted");
                }
                else
                {
                    SMLog("deleted");
                }
            }
        }
    }
    
    class func removeFolderAtPath(_ folderPath : URL) -> Bool
    {
        let manager : Foundation.FileManager = Foundation.FileManager.default
        
        var directory = ObjCBool(true)
        var status : Bool = true
        
        if (manager.fileExists(atPath: folderPath.path, isDirectory:&directory))
        {
            do {
                try manager.removeItem(atPath: folderPath.path)
                status = true
            } catch _ {
                status = false
            }
        }
        
        return status
    }
    
    class func copyNewTemplateFileToApplicationSupport(_ sourcePath : String) -> Bool
    {
        let fileManager : Foundation.FileManager = Foundation.FileManager()
        
        let finalPath : String = FileManager.applicationDirectory().appendingPathComponent(URL(fileURLWithPath: sourcePath).lastPathComponent)

        if fileManager.fileExists(atPath: finalPath)
        {
            SMLog("existe");
            
            var error : NSError?
            
            var status : Bool
            do {
                try fileManager.removeItem(atPath: finalPath)
                status = true
            } catch let error1 as NSError {
                error = error1
                status = false
            }
            
            if (status && error == nil)
            {
                SMLog("borrado");
            }
            else
            {
                SMLog("no borrado");
            }
        }
        else
        {
            SMLog("no existe");
        }
        
        var error : NSError?

        var status : Bool
        do {
            try fileManager.copyItem(atPath: sourcePath, toPath: finalPath)
            status = true
        } catch let error1 as NSError {
            error = error1
            status = false
        }
        
        if (status && error == nil)
        {
            return true
        }
        else
        {
            SMLog("Error: " + error!.localizedDescription)
            
            return false
        }
    }
    
    class func resolvePathForFile(_ fileName: String) -> String
    {
        let fileManager : Foundation.FileManager = Foundation.FileManager()

        let finalPath : String = FileManager.applicationDirectory().appendingPathComponent(fileName)
        
        if (fileManager.fileExists(atPath: finalPath))
        {
            return finalPath
        }
        
        return URL(fileURLWithPath: FileManager.templatesPath()).appendingPathComponent(fileName).path
    }
}
