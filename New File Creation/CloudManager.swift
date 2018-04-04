//
//  CloudManager.swift
//  New File Creation
//
//  Created by sid on 05/09/15.
//  Copyright (c) 2015 com.sergiomtzlosa.filecreation. All rights reserved.
//

import Foundation
import AppKit

let fileArchive = "new_file_creation_bk.zip"

//let containerUbiquity = "iCloud.com.sergiomtzlosa.filecreation"

class CloudManager
{
    static var cloudPath : URL?
    
    class func uploadToCloud(_ source: String, destination: URL) -> Bool
    {
        let srcURL : URL = URL(fileURLWithPath: source)
        
        let destinationURL : URL = destination.appendingPathComponent("Documents", isDirectory : true).appendingPathComponent(fileArchive)
        
        var error : NSError?
        
        if (fileExists(destinationURL.path))
        {
            do {
                try Foundation.FileManager.default.setUbiquitous(false, itemAt: srcURL, destinationURL: destinationURL)
            } catch let error1 as NSError {
                error = error1
                SMLog(error1.localizedDescription)
            }
            
            var err : NSError?
            let fileCoordinator : NSFileCoordinator = NSFileCoordinator(filePresenter: nil)
            
            fileCoordinator.coordinate(writingItemAt: destinationURL, options: NSFileCoordinator.WritingOptions.forDeleting, error: &err, byAccessor: { ( writingURL : URL!) -> Void in
                
                do {
                    try Foundation.FileManager.default.removeItem(at: writingURL)
                } catch let error1 as NSError {
                    error = error1
                    SMLog(error1.localizedDescription)
                }
                
            })
        }
        
        SMLog(srcURL)
        SMLog(destinationURL)
        
        error = nil
        var status : Bool
        do {
            try Foundation.FileManager.default.setUbiquitous(true, itemAt: srcURL, destinationURL: destinationURL)
            status = true
        } catch let error1 as NSError {
            error = error1
            status = false
        }
        
        if status && error == nil
        {
            SMLog("true upload")
            return true
        }
        else
        {
            SMLog("false upload")
            return false
        }
    }

    class func downloadFromCloud(_ destination: URL) -> Bool
    {
        if (fileExists(destination.path))
        {
            do {
                try Foundation.FileManager.default.removeItem(at: destination)
            } catch _ {
            }
        }
        
        // download from iCloud
        let source : URL = CloudManager.cloudPath!.appendingPathComponent("Documents", isDirectory : true).appendingPathComponent(fileArchive)
        
        let fileManager : Foundation.FileManager = Foundation.FileManager.default
        
        var theError: NSError?
        
        var started : Bool
        do {
            try fileManager.startDownloadingUbiquitousItem(at: source)
            started = true
        } catch let error as NSError {
            theError = error
            started = false
        }
        
        SMLog("started download for \(started)");
        
        if (theError != nil)
        {
            SMLog("iCloud error: \(theError!.localizedDescription)")
            
            return false
        }
        
        return unzipFile(source.path, destination: destination.deletingLastPathComponent().path)
    }
    
    class func unzipFile(_ source : String, destination : String) -> Bool
    {
        let arguments : NSArray = NSArray(arrayLiteral: "-o", source)
        
        let unzipTask : Process = Process()
        
        unzipTask.launchPath  = "/usr/bin/unzip"
        unzipTask.currentDirectoryPath = destination
        unzipTask.arguments = arguments as? [String]
        
        let output : Pipe = Pipe()
        unzipTask.standardOutput = output
        unzipTask.standardInput = Pipe()

        unzipTask.launch()
        unzipTask.waitUntilExit()
        
        let read : FileHandle = output.fileHandleForReading
        let dataRead : Data = read.readDataToEndOfFile()
        let stringRead : NSString = NSString(data: dataRead, encoding: String.Encoding.utf8.rawValue)!
        
        SMLog("output: \(stringRead)")
        
        if (stringRead == "")
        {
            return false
        }
        
        return true
    }
    
    class func fileExists(_ pathFile : String) -> Bool
    {
        let checkValidation = Foundation.FileManager.default
        
        if (checkValidation.fileExists(atPath: pathFile))
        {
            SMLog("FILE AVAILABLE");
            return true
        }
        else
        {
            SMLog("FILE NOT AVAILABLE");
            return false
        }
    }
    
    class func removeFileAtPath(_ pathFile : String) -> Bool
    {
        let checkValidation = Foundation.FileManager.default
        
        var error: NSError?
        
        var status : Bool
        do {
            try checkValidation.removeItem(atPath: pathFile)
            status = true
        } catch let error1 as NSError {
            error = error1
            status = false
        }
        
        if status && error == nil
        {
            SMLog("FILE removed");
            return true
        }
        else
        {
            SMLog("FILE NOT removed");
            return false
        }
    }
    
    class func zipCloudFiles() -> String
    {
        let folderPath : String = FileManager.applicationDirectory() as String
        let finalFilePath : String = "\(folderPath)/\(fileArchive)"
        
        if (fileExists(finalFilePath))
        {
            _ = removeFileAtPath(finalFilePath)
        }
        
        let files : NSMutableArray = NSMutableArray()
        
//        var error: NSError? = nil
        let fileManager = Foundation.FileManager.default
    
        let contents: [AnyObject]?
        do {
            contents = try fileManager.contentsOfDirectory(atPath: folderPath) as [AnyObject]?
        } catch let error1 as NSError {
//            error = error1
            SMLog(error1.localizedDescription)
            contents = nil
        }
        
        if contents == nil
        {
            return ""
        }
        else
        {
//            var filenames: [String] = contents as! [String]

            for item in contents as! [String]
            {
                if (!item.containsString("application_prefs"))
                {
                    let item : String = "\(folderPath)/\(item)"
                    
                    files.add(item)
                    
                    SMLog(item)
                }
            }
        }
        
        
        SMLog(files)
        SMLog(finalFilePath)
        
        let status = ZipArchive.createZipFile(atPath: finalFilePath, withFilesAtPaths: files as [AnyObject])
        
        SMLog(status)
        
        if (status)
        {
            return finalFilePath
        }
        else
        {
            return ""
        }
    }
    
    class func checkCloudAvailable() -> Bool
    {
        let group : DispatchGroup  = DispatchGroup()
        let notified = DispatchSemaphore(value: 0)
        
        let qualityOfServiceClass = DispatchQoS.QoSClass.background
        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
        
        var status : Bool = false
        
        group.enter()
        
        backgroundQueue.async(group: group, execute: {

            CloudManager.cloudPath = CloudManager.isCloudAvailable()
            
            SMLog(CloudManager.cloudPath?.absoluteString as Any)
            
            let isAvailable : Bool = (CloudManager.cloudPath != nil) ? true : false
            
            if (isAvailable)
            {
                SMLog("available")
                
                status = true
            }
            else
            {
                SMLog("not available")
            }
            
            group.leave()
        })
        
        group.notify(queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default), execute: { () -> Void in
            
            SMLog("finally!")
            notified.signal()
        })
        
        // Block this thread until all tasks are complete
        _ = group.wait(timeout: DispatchTime.distantFuture)
        
        // Wait until the notify block signals our semaphore
        _ = notified.wait(timeout: DispatchTime.distantFuture)
        
        SMLog("status: " + ((status) ? "true" : "false"))
        
        return status
    }

    fileprivate class func isCloudAvailable() -> URL?
    {
        let ubiquityURL : URL? = Foundation.FileManager.default.url(forUbiquityContainerIdentifier: nil)
        
        SMLog(ubiquityURL?.absoluteString as Any)
        
        return ubiquityURL;
    }
}
