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

let kTagAdjust = 100

let kFinderExtensionUpdate = "FinderSynxNotificationNewFile"

class FinderSync: FIFinderSync
{
    let finderController = FIFinderSyncController.default()

    var isShowing : Bool?
    var templates : NSArray!
    var popupButton : NSPopUpButton!
    var savePanel : NSSavePanel!
    var customView : NSView!
    var appSettings : NSDictionary!
    var arrayPaths : Set<NSObject>! = []
    var usernamePath : String!
    var subMenu : NSMenu!
    
    override init()
    {
        print("enter extension")
        super.init()
  
        self.isShowing = false
        self.templates = self.obtainRows()
 
        customView = newAccessoryView()

        self.arrayPaths = Set()
        
        _ = VolumeManager.shared
        
        SMLog("FinderSync() launched from %@", Bundle.main.bundlePath)

        // Set up the directory we are syncing.
        
        self.usernamePath = "/Users/" + NSUserName()
       
        self.finderController.directoryURLs = self.getExtensionURLFinder()
        SMLog("%@", self.getExtensionURLFinder())

        NotificationCenter.default.addObserver(forName:VolumeManager.VolumesDidChangeNotification, object:nil, queue:OperationQueue.current!) { (notification) in

//            var urls = Set(notification.object as! [URL])
//
//            urls.insert(URL(fileURLWithPath: self.usernamePath))
//            urls = urls.union(Set(urls))
//            urls = urls.union(self.getExtensionURLFinder())
//
//            SMLog("items urls notification: \(urls)")
//
//            self.finderController.directoryURLs = urls
            
            let notifObject : NSArray! = notification.object as? NSArray
          
            let urls : NSMutableArray = NSMutableArray()
      
            if ((notifObject) != nil)
            {
                urls.addObjects(from: notifObject as! [Any])
            }
        
            urls.add(NSURL(fileURLWithPath: self.usernamePath))
           
            SMLog("urls: \(urls)")
          
            let finalSet : NSMutableSet = NSMutableSet()
          
            finalSet.addObjects(from: urls as! [Any])
  
            let externalDisk = self.getExtensionURLFinder()
           
            finalSet.union(externalDisk)
        
            self.finderController.directoryURLs = finalSet as? Set<URL>
            
            SMLog("notification: %@", finalSet)
        }
    }
    
    func getExtensionURLFinder() -> Set<URL>
    {
        arrayPaths.insert(URL(fileURLWithPath: usernamePath) as NSObject)
        
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
        
        return arrayPaths as! Set<URL>
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
    
    func createSubMenus(menu: NSMenu, item: NSMenuItem) -> NSMenu {

        let submenu = NSMenu(title: "")
        menu.setSubmenu(submenu, for: item)

        var indexTag : Int = 0
        var subMenuItem : NSMenuItem
        self.templates = self.obtainRows()
        
        for file in self.templates {

            let components : [String] = (file as AnyObject).components(separatedBy: ".")

            var extensionFile : String = "sh"

            if (components.count > 1) {
                extensionFile = components[1].uppercased() as String
            }

            let strTitle : NSString = NSString(format: "New %@", file as! NSString)

            subMenuItem = NSMenuItem(title: strTitle as String, action: #selector(FinderSync.subMenuAction(_:)), keyEquivalent: "")
            subMenuItem.tag = indexTag + kTagAdjust
            subMenuItem.indentationLevel = 0

            var imageIcon : NSImage = NSWorkspace.shared.icon(forFileType: extensionFile)
            imageIcon = Utils.resize(image: imageIcon, w: 20, h: 20)
 
            subMenuItem.image = imageIcon

            submenu.addItem(subMenuItem)

            indexTag += 1
        }

        return menu
    }
    
    @IBAction func showHUDPanel(_ sender: AnyObject?) {
        
        SCHEDULE_DISTRIBUTED_NOTIFICATION(name: kFinderExtensionUpdate)
    }
    
    @IBAction func subMenuAction(_ sender: AnyObject?) {

        let item = sender as! NSMenuItem

        let tag : Int = item.tag - kTagAdjust

        let rows : [String] = self.createRows() as! [String]
        
        self.popupButton.removeAllItems()
//        self.popupButton.addItems(withTitles: rows)
        
        popupButton.imagePosition = .imageLeft
        popupButton.menu = self.recreatePopUpMenu(rowsItem: rows)
        
        self.popupButton.selectItem(at: tag)
        
        launchSavePanel(indexTemplate: tag)
    }
    
    func baseMenu() -> SMMenu {
        
        let menu = SMMenu(title: "")
        
        let itemHUD = NSMenuItem(title: "Fast New File Creation...", action: #selector(FinderSync.showHUDPanel(_:)), keyEquivalent: "")
        itemHUD.image = NSImage(named: "Icon")
        
        menu.addItem(itemHUD)
        
        return menu
    }
    
    func addSeparatorTo(menu: NSMenu) -> NSMenu {
        
//        _ =  menu.addItem(withTitle: "---", action: nil, keyEquivalent: "")
        
        
        return menu
    }
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        
        // Produce a menu for the extension.
        
        let menu: SMMenu = baseMenu()
    
//        menu = addSeparatorTo(menu: menu)
        
        let item: NSMenuItem
        
        if #available(OSX 11.0, *) {
            
            if (menuKind == FIMenuKind.contextualMenuForContainer)
            {
                item = NSMenuItem(title: "New File Creation...", action: nil, keyEquivalent: "")
                item.image = NSImage(named: "Icon")
                menu.addItem(item)
                
                let subMenu: NSMenu = createSubMenus(menu: menu, item: item)
            
                return subMenu
            }
            
        } else {
            
            if (menuKind == FIMenuKind.contextualMenuForContainer)
            {
                item = NSMenuItem(title: "New File Creation...", action: #selector(FinderSync.createNewFile(_:)), keyEquivalent: "")
                item.image = NSImage(named: "Icon")
                menu.addItem(item)
       
                _ = menu.insertItem(withTitle: "---", action: nil, keyEquivalent: "", at: 1)
                
                return menu
            }
        }
        
        if (menuKind == FIMenuKind.contextualMenuForItems)
        {
            let paths : [URL]? = FIFinderSyncController.default().selectedItemURLs()
            
            if (paths != nil) {
                
                if urlsAreFiles(paths: paths!) {
                    
                    let menu = NSMenu(title: "")
                    
                    item = NSMenuItem(title: SMLocalizedString("add_as_template"), action: #selector(FinderSync.addAsTemplate(_:)), keyEquivalent: "")
                    item.image = NSImage(named: "Icon")
                    
                    menu.addItem(item)
                 
                    return menu
                }
            }
        }

        return nil
    }

    func urlsAreFiles(paths: [URL]) -> Bool {
        
        if (paths.count == 0) {
            
            return false;
        }
        
        var isFile : Bool = true
        
        for url in paths {
            
            if url.isDirectory == true {
                
                isFile = false
                break
            }
        }
        
        return isFile
    }
    
    @IBAction func addAsTemplate(_ sender: AnyObject?) {

        let paths : [URL]? = FIFinderSyncController.default().selectedItemURLs()
        
        if (paths != nil) {
            if paths!.count > 0 {
                
                var finalPaths : [String] = []
                
                for url in paths! {
                    
                    if url.isDirectory == false {
                        
                        finalPaths.append(url.path)
                    }
                }
                
                if finalPaths.count > 0 {
                    
                    _ = Preferences.setSelectedFilesExtension(files: finalPaths)
                    
                    // Add as template send notification
                    SCHEDULE_DISTRIBUTED_NOTIFICATION(name: kAddFileFromFinder)
                    SMLog("Notification sent to add new file from Finder as template!!!")
                }
            }
        }
    }
    
    @IBAction func createNewFile(_ sender: AnyObject?)
    {
        let rows : [String] = self.createRows() as! [String]
        
        self.popupButton.removeAllItems()
//        self.popupButton.addItems(withTitles: rows)
        
        self.popupButton.imagePosition = .imageLeft
        self.popupButton.menu = self.recreatePopUpMenu(rowsItem: rows)
        
        self.popupButton.selectItem(at: 0)
        
        launchSavePanel()
    }
    
    func launchSavePanel(indexTemplate : Int = 0)
    {
        if isShowing == true
        {
            return
        }
        
        self.isShowing = true
 
        let target = self.finderController.targetedURL()
        
        DispatchQueue.main.async(execute: {
            
            self.savePanel = NSSavePanel()
            
            let templateFile : String = self.templates[indexTemplate] as! String
            let split : [String] = templateFile.components(separatedBy: ".")
            let extensionString : String = split[1]
            
            self.savePanel.nameFieldStringValue = kFileName + "." + extensionString
            self.savePanel.becomeFirstResponder()
            self.savePanel.title = (currentLanguage() == "es" || currentLanguage() == "es-es") ? "Guardar nuevo archivo como..." : "Save new file as..."
            self.savePanel.showsTagField = false
            self.savePanel.showsHiddenFiles = false
            self.savePanel.showsToolbarButton = true
            self.savePanel.canCreateDirectories = true
            self.savePanel.accessoryView = self.customView
            self.savePanel.becomeMain()
            self.savePanel.level = .modalPanel//NSWindow.Level(rawValue: 0)//CGWindowLevelKey.ModalPanelWindowLevelKey
            self.savePanel.showsResizeIndicator = false
            self.savePanel.disableSnapshotRestoration()
            self.savePanel.isExtensionHidden = false
            self.savePanel.allowedFileTypes = nil
            self.savePanel.center()
         
            NSApp.mainWindow?.makeKeyAndOrderFront(self.savePanel)
            self.savePanel.makeKeyAndOrderFront(nil)
            
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
//                self.popupButton.addItems(withTitles: rows)
                
                self.popupButton.imagePosition = .imageLeft
                self.popupButton.menu = self.recreatePopUpMenu(rowsItem: rows)
                
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
//                    self.popupButton.addItems(withTitles: rows)
                    
                    self.popupButton.imagePosition = .imageLeft
                    self.popupButton.menu = self.recreatePopUpMenu(rowsItem: rows)
                    
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
                            NSSound.init(named: "dropped")?.play()
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
//                    self.popupButton.addItems(withTitles: rows)
                    
                    self.popupButton.imagePosition = .imageLeft
                    self.popupButton.menu = self.recreatePopUpMenu(rowsItem: rows)
                    
                    self.popupButton.selectItem(at: 0)
                    
                    self.isShowing = false
                }
            }
        })
    }
    
    func recreatePopUpMenu(rowsItem : [String]) -> NSMenu {
        
        let mainMenu: NSMenu = NSMenu(title: "")
        
        for rowString in rowsItem {

            let tempStr : [String] = (rowString as String).components(separatedBy: "-")
            let components : [String] = (tempStr[1] as String).trimmingCharacters(in: .whitespaces).components(separatedBy: ".")

            var extensionFile : String = "sh"

            if (components.count > 1) {
                extensionFile = components[1].trimmingCharacters(in: .whitespaces).uppercased() as String
            }
       
            var imageIcon : NSImage = NSWorkspace.shared.icon(forFileType: extensionFile)
            imageIcon = Utils.resize(image: imageIcon, w: 12, h: 12)
     
            let menuItemRow: NSMenuItem = NSMenuItem(title: rowString, action: nil, keyEquivalent: "")
            menuItemRow.image = imageIcon
            
            mainMenu.addItem(menuItemRow)
        }
        
        return mainMenu
    }
    
    func newAccessoryView() -> NSView?
    {
        let accesoryView : NSView = NSView(frame: NSMakeRect(0, 0, 450, 50))
        
        accesoryView.wantsLayer = true
        accesoryView.layer?.backgroundColor = NSColor.clear.cgColor
        
        let labelField : NSTextField = NSTextField(frame: NSMakeRect(8, 16, 150, 19))
        
        labelField.textColor = (isDarkModeEnabled()) ? NSColor.white : NSColor.black
        labelField.stringValue = (currentLanguage() == "es" || currentLanguage() == "es-es") ? "Selecciona un tipo:" : "Select a file type:"
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
        
//        popupButton.addItems(withTitles: rows)

        popupButton.imagePosition = .imageLeft
        popupButton.menu = self.recreatePopUpMenu(rowsItem: rows)
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
            let components : [String] = (file as AnyObject).components(separatedBy: ".")
            
            var extensionFile : String = "sh"
            
            if (components.count > 1)
            {
                extensionFile = components[1].uppercased() as String
            }
         
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
            let components : [String] = (file as AnyObject).components(separatedBy: ".")
            
            var extensionFile : String = "sh"
            
            if (components.count > 1)
            {
                extensionFile = components[1].uppercased() as String
            }
            
//            let extensionFile : String = components[1].uppercased()
            
            var str : NSString = NSString(format: "New .%@ file - %@", extensionFile, file as! NSString)
                
            if (currentLanguage() == "es" || currentLanguage() == "es-es")
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
            
            let split : [String] = templateFile.components(separatedBy: ".")
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
