//
//  FinderSync.swift
//  New File Creation Extension
//
//  Created by sid on 08/08/15.
//  Copyright (c) 2015 com.sergiomtzlosa.filecreation. All rights reserved.
//

import Cocoa
import FinderSync

let kFileName = "NewFile"

class FinderSync: FIFinderSync
{
    var isShowing : Bool?
    var templates : NSArray!
    var popupButton : NSPopUpButton!
    var savePanel : NSSavePanel!
    var customView : NSView!
    var appSettings : NSDictionary!
    var arrayPaths : Set<NSObject>! = []
    
    override init()
    {
        super.init()
  
        self.isShowing = false
        self.templates = obtainRows()
        customView = newAccessoryView()

        SMLog("FinderSync() launched from %@", Bundle.main.bundlePath)

        // Set up the directory we are syncing.
        
        arrayPaths.insert(URL(fileURLWithPath: "/") as NSObject)
        var itemsURL : NSArray? = Volumes.mountedVolumes() as NSArray?
        
        if itemsURL != nil
        {
            let array : NSArray = NSArray(array: itemsURL!)
            
            for item in array
            {
                let url : URL = item as! URL

                arrayPaths.insert(url as NSObject)
            }
        }
        
        itemsURL = Volumes.mountedAllVolumes() as NSArray?
        
        if itemsURL != nil
        {
            let array : NSArray = NSArray(array: itemsURL!)
            
            for item in array
            {
                let url : URL = item as! URL
                
                arrayPaths.insert(url as NSObject)
            }
        }
        
        FIFinderSyncController.default().directoryURLs = arrayPaths as! Set<URL>
    }
    
    func obtainRows() -> NSArray
    {
        appSettings = Preferences.readPlistApplicationPreferences()
        let tempArray : NSMutableArray = NSMutableArray()
        
        let array : NSArray = Preferences.readPlistTemplatePreferences()
        
        SMLog(array)
        
        for item in array
        {
            let temp = item as! [NSString : NSObject]
            
            let obj : NSMutableDictionary = NSMutableDictionary()
            
            for (key, value) in temp
            {
                obj.setObject(value, forKey: key)
            }
            
            //let obj = item as! NSDictionary
            let tempActive : Any? = obj.object(forKey: "active")
            let active: Bool = tempActive as! Bool
            
            let tempEnabled : Any? = obj.object(forKey: "enableColumn")
            let enabled: Bool = tempEnabled as! Bool
            
            if (active == true && enabled == true)
            {
                tempArray.add(obj.object(forKey: "templateColumn")!)
            }
        }
        
        let finalArray : NSArray = NSArray(array: tempArray)
        return finalArray
    }
    
    // MARK: - Primary Finder Sync protocol methods

    override func beginObservingDirectory(at url: URL)
    {
        // The user is now seeing the container's contents.
        // If they see it in more than one view at a time, we're only told once.
//        SMLog("beginObservingDirectoryAtURL: %@", url.path)
    }

    override func endObservingDirectory(at url: URL)
    {
        // The user is no longer seeing the container's contents.
//        SMLog("endObservingDirectoryAtURL: %@", url.path)
    }

    override func requestBadgeIdentifier(for url: URL)
    {
//        SMLog("requestBadgeIdentifierForURL: %@", url.filePathURL!)
    }

    // MARK: - Menu and toolbar item support

    override var toolbarItemName: String
    {
        return ""
    }

    override var toolbarItemToolTip: String
    {
        return ""
    }

//    override var toolbarItemImage: NSImage {
//        return nil
//    }

    override func menu(for menuKind: FIMenuKind) -> NSMenu?
    {
        // Produce a menu for the extension.
        
        if (menuKind == FIMenuKind.contextualMenuForContainer)
        {
            let menu = NSMenu(title: "")
            menu.addItem(withTitle: "New File Creation...", action: #selector(FinderSync.createNewFile(_:)), keyEquivalent: "")
            let item: NSMenuItem = menu.items[0]
            item.image = NSImage(named: NSImage.Name(rawValue: "Icon"))
            return menu
        }
        
        return nil
    }

    @IBAction func createNewFile(_ sender: AnyObject?)
    {
        let rows : [String] = self.createRows() as! [String]
        
        self.popupButton.removeAllItems()
        self.popupButton.addItems(withTitles: rows)
        self.popupButton.selectItem(at: 0)
        
        launchSavePanel()
    }
    
    func launchSavePanel()
    {
        if isShowing == true
        {
            return
        }
        
        self.isShowing = true
 
        let target = FIFinderSyncController.default().targetedURL()
        
        DispatchQueue.main.async(execute: {
            
            self.savePanel = NSSavePanel()
            
            let templateFile : String = self.templates[0] as! String
            var split : [String] = templateFile.components(separatedBy: ".")
            let extensionString : String = split[1]
            
            self.savePanel.nameFieldStringValue = kFileName + "." + extensionString
            self.savePanel.becomeFirstResponder()
            self.savePanel.title = (currentLanguage() == "es") ? "Guardar nuevo archivo como..." : "Save new file as..."
            self.savePanel.showsTagField = false
            self.savePanel.showsHiddenFiles = false
            self.savePanel.showsToolbarButton = true
            self.savePanel.canCreateDirectories = true
            self.savePanel.accessoryView = self.customView
            self.savePanel.becomeMain()
            self.savePanel.level = NSWindow.Level(rawValue: 0)//CGWindowLevelKey.ModalPanelWindowLevelKey
            self.savePanel.showsResizeIndicator = false
            self.savePanel.disableSnapshotRestoration()
            self.savePanel.isExtensionHidden = false
            self.savePanel.allowedFileTypes = nil
            self.savePanel.center()
         
            NSApp.mainWindow?.makeKeyAndOrderFront(self.savePanel)
            
            let destination : URL = target!
            
//            var desktopPath : String = (NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DesktopDirectory, NSSearchPathDomainMask.UserDomainMask, true) as NSArray).objectAtIndex(0) as! String
//           
//            SMLog(desktopPath)
            
            self.savePanel.directoryURL = destination
            self.savePanel.isAutodisplay = true
//            let result : NSInteger = self.savePanel.runModal()
            var error : NSError?

            if (error != nil)
            {
                SMLog(error!.localizedDescription)
                NSApp.presentError(error!)
                
                let rows : [String] = self.createRows() as! [String]
                
                self.popupButton.removeAllItems()
                self.popupButton.addItems(withTitles: rows)
                self.popupButton.selectItem(at: 0)
                
                self.isShowing = false
                
                return
            }
            
            
//            self.savePanel.beginSheet(NSWindow, completionHandler: { ((NSApplication.ModalResponse) -> Void)? = nil) in
            
         
            self.savePanel.begin { ( result :NSApplication.ModalResponse) in
                
//                if result == NSFileHandlingPanelCancelButton
                if (result == NSApplication.ModalResponse.cancel)
                {
                    let rows : [String] = self.createRows() as! [String]
                    
                    self.popupButton.removeAllItems()
                    self.popupButton.addItems(withTitles: rows)
                    self.popupButton.selectItem(at: 0)
                    
                    self.isShowing = false
                }
                
//                if result == NSFileHandlingPanelOKButton
                if (result == NSApplication.ModalResponse.OK)
                {
                    let valueFile : String = self.templates[self.popupButton.indexOfSelectedItem] as! String
                    //var components : [String] = valueFile.componentsSeparatedByString(".") as [String]
                    
                    //let extensionFile : String = components[1].lowercaseString
                    
                    let source : String = FileManager.resolvePathForFile(valueFile)
                    let destination : String = (self.savePanel.url! as NSURL).filePathURL!.resolvingSymlinksInPath().path
                    
                    self.savePanel.directoryURL = URL(fileURLWithPath: destination)
                    
                    let fileManager = Foundation.FileManager.default
                    
                    if fileManager.fileExists(atPath: destination) {
                        
                        SMLog("archivo existe: \(destination)")
                        
                        do {
                            try fileManager.removeItem(at: URL(fileURLWithPath: destination))
                        } catch let error1 as NSError {
                            error = error1
                            SMLog("error: \(error!.localizedDescription)")
                        } catch {
                            SMLog("error")
                        }
                    }
                    
                    do {
                        try Foundation.FileManager.default.copyItem(atPath: source, toPath: destination)
                        SMLog("copied")
                        
                        let soundEnabled : Int = self.appSettings.object(forKey: "soundEnabled") as! Int
                        
                        if (soundEnabled == 1)
                        {
                            NSSound.init(named: NSSound.Name("dropped"))?.play()
                        }
                        
                        let openOncreation : Int = self.appSettings.object(forKey: "openOncreation") as! Int
                        
                        if (openOncreation == 1)
                        {
                            Utils.openFile(destination)
                        }
                        
                        let revealOnCreation : Int = self.appSettings.object(forKey: "revealOnCreation") as! Int
                        
                        if (revealOnCreation == 1)
                        {
                            Utils.revealInFinder(destination)
                        }
                    } catch let error1 as NSError {
                        error = error1
                        SMLog("error: \(error!.localizedDescription)")
                    } catch {
                        SMLog("error")
                    }
                    
                    let rows : [String] = self.createRows() as! [String]
                    
                    self.popupButton.removeAllItems()
                    self.popupButton.addItems(withTitles: rows)
                    self.popupButton.selectItem(at: 0)
                    
                    self.isShowing = false
                }
            }
        })
    }
    
    func newAccessoryView() -> NSView?
    {
        let accesoryView : NSView = NSView(frame: NSMakeRect(0, 0, 450, 50))
        
        accesoryView.wantsLayer = true
        accesoryView.layer?.backgroundColor = NSColor.clear.cgColor
        
        let labelField : NSTextField = NSTextField(frame: NSMakeRect(8, 16, 150, 19))
        
        labelField.textColor = NSColor.black
        labelField.stringValue = (currentLanguage() == "es") ? "Selecciona un tipo:" : "Select a file type:"
        labelField.alignment = NSTextAlignment.left
        labelField.font = NSFont.systemFont(ofSize: 13)
        labelField.isBezeled = false
        labelField.drawsBackground = false
        labelField.isEditable = false
        labelField.isSelectable = false
        labelField.backgroundColor = NSColor.clear
        
        accesoryView.addSubview(labelField)
        
        popupButton = NSPopUpButton(frame: NSMakeRect(172, 12, 250, 25))
        
        let rows : [String] = self.createRows() as! [String]
        
        popupButton.addItems(withTitles: rows)
        popupButton.selectItem(at: 0)

        popupButton.action = #selector(FinderSync.changeValuePopUpButton(_:))
        popupButton.target = self
        
        accesoryView.addSubview(popupButton)

        return accesoryView
    }
    
    fileprivate func extensions() -> NSArray
    {
        let extensionsArray : NSMutableArray = NSMutableArray()
        
        self.templates = obtainRows()
        
        for file in self.templates
        {
            var components : [String] = (file as AnyObject).components(separatedBy: ".") 
            
            let extensionFile : String = components[1].uppercased()
   
            extensionsArray.add(extensionFile)
        }
        
        return extensionsArray
    }
    
    fileprivate func createRows() -> NSArray
    {
        let rowFiles : NSMutableArray = NSMutableArray()
        
        self.templates = obtainRows()
        
        for file in self.templates
        {
            var components : [String] = (file as AnyObject).components(separatedBy: ".") 
            
            let extensionFile : String = components[1].uppercased()
            
            var str : NSString = NSString(format: "New .%@ file - %@", extensionFile, file as! NSString)
                
            if (currentLanguage() == "es")
            {
                str = NSString(format: "Nuevo archivo .%@ - %@", extensionFile, file as! NSString)
            }
           
            let stringValue : String = str as String
            
            rowFiles.add(stringValue)
        }
        
        return rowFiles
    }
    
    @objc func changeValuePopUpButton(_ sender: AnyObject)
    {
        if let pub = sender as? NSPopUpButton
        {
            SMLog(pub.titleOfSelectedItem as Any)
            SMLog(pub.indexOfSelectedItem)
  
            let templateFile : String = self.templates[pub.indexOfSelectedItem] as! String
            
            var split : [String] = templateFile.components(separatedBy: ".")
            let extensionString : String = split[1]
            
            SMLog("templateFile \(templateFile) as AnyObject?")
            SMLog("extensionString \(extensionString)")
            
            savePanel.allowedFileTypes = [extensionString]
            savePanel.nameFieldStringValue = "NewFile." + extensionString
        }
    }
    
    func refreshComboPreferences()
    {
        customView = newAccessoryView()
    }
}
