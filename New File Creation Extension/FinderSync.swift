//
//  FinderSync.swift
//  New File Creation Extension
//
//  Created by sid on 08/08/15.
//  Copyright (c) 2015 com.sergiomtzlosa.filecreation. All rights reserved.
//

import Cocoa
import FinderSync
//import New_File_Creation_Helper

let CELL_HEIGHT : CGFloat = 50

let kFileName = "NewFile"

let kTagAdjust = 100

let kFinderExtensionUpdate = "FinderSynxNotificationNewFile"

class FinderSync: FIFinderSync//, NSTableViewDataSource, NSTableViewDelegate
{
    let finderController = FIFinderSyncController.default()

//    var tableContext: NSTableView!
//    var tableScrollView: SMScrollView!
    
    var isShowing : Bool?
    var templates : NSMutableArray!
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
//        self.tableScrollView = createContextTableView()
//        tableContext.reloadData()
        
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
    
    func obtainRows() -> NSMutableArray
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
        
        let finalArray : NSMutableArray = NSMutableArray(array: tempArray)
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
    
    func baseMenu() -> NSMenu {
        
        let menu = NSMenu(title: "")
        
        let itemHUD = NSMenuItem(title: "Fast New File Creation...", action: #selector(FinderSync.showHUDPanel(_:)), keyEquivalent: "")
        itemHUD.image = NSImage(named: "Icon")
        
        menu.addItem(itemHUD)
        
        return menu
    }
    
//    func addSeparatorTo(menu: NSMenu) -> NSMenu {
//
//        let separator : NSMenuItem = NSMenuItem(title: "", action: nil, keyEquivalent: "")
//
//        let sepView: NSView = NSView(frame: NSRect(x: 0, y: 0, width: 30, height: 1))
//        separator.view?.wantsLayer = true
//
//        sepView.layer?.backgroundColor = NSColor.lightGray.cgColor
//
//        separator.view = sepView
//
//        menu.addItem(separator)
//
////        [menu cancelTracking];
////        menu performActionForItemAtIndex:[menu indexOfItem:separator]];
//        menu.performActionForItem(at: menu.index(of: separator))
//           menu.removeItem(separator)
//        return menu
//    }
    
    // MARK: - Menu and toolbar item support
    override var toolbarItemName: String {
    
        return "New File Creation..."
    }

    override var toolbarItemImage: NSImage {
    
        return NSImage(named: "Icon")!
    }
    
//    func createContextTableView() -> SMScrollView {
//
//        let sizeView: NSSize = NSSize(width: 364, height:450)
//
//        let overlayScrollView : SMScrollView = SMScrollView(frame: NSMakeRect(-10, 0, sizeView.width + 50, sizeView.height - 30))
//
//        overlayScrollView.verticalLineScroll = 1.0
//        overlayScrollView.verticalPageScroll = 1.0
//        overlayScrollView.hasVerticalScroller = true
//        overlayScrollView.backgroundColor = NSColor.clear
//        overlayScrollView.scrollerStyle = NSScroller.Style.overlay
//        overlayScrollView.hasHorizontalScroller = false
//        overlayScrollView.drawsBackground = false
//        overlayScrollView.pageScroll = overlayScrollView.contentSize.height
//        overlayScrollView.scrollerKnobStyle = NSScroller.KnobStyle.dark
//        overlayScrollView.wantsLayer = true
//
//        self.tableContext = NSTableView(frame: NSMakeRect(0, 0, sizeView.width, sizeView.height))
//
//        // Set style to plain to prevent any inset
//        if #available(OSX 11.0, *) {
//            self.tableContext.style = .plain
//        }
//
//        tableContext.enclosingScrollView?.borderType = .noBorder
//
//        tableContext.target = self
////        tableContext.doubleAction = #selector(AppDelegate.doubleClick(_:))
//
//        tableContext.selectionHighlightStyle = NSTableView.SelectionHighlightStyle.none
//        tableContext.layer?.cornerRadius = 0
//        tableContext.layer?.borderColor = NSColor.clear.cgColor
//        tableContext.headerView = nil
//        tableContext.layer?.backgroundColor = NSColor.clear.cgColor
//        tableContext.delegate = self
//        tableContext.dataSource = self
//        tableContext.backgroundColor = NSColor.clear
//
//        // Registering dragged Types
//
//        let NSFilenamesPboardTypeTemp = NSPasteboard.PasteboardType("NSFilenamesPboardType")
//
//        // NSFilenamesPboardType
//        tableContext.registerForDraggedTypes([NSFilenamesPboardTypeTemp])
//
//        //To support across application passing NO
//        tableContext.setDraggingSourceOperationMask(NSDragOperation.copy, forLocal: false)
//
//        let column1 : NSTableColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "columnWindow1"))
//
//        column1.width = sizeView.width
//
//        column1.resizingMask = NSTableColumn.ResizingOptions.autoresizingMask
//
//        tableContext.addTableColumn(column1)
//
//        tableContext.columnAutoresizingStyle = NSTableView.ColumnAutoresizingStyle.uniformColumnAutoresizingStyle
//        column1.resizingMask = NSTableColumn.ResizingOptions.autoresizingMask
//        tableContext.sizeLastColumnToFit()
//
//        overlayScrollView.documentView = self.tableContext
//
//        tableContext.setNeedsDisplay()
//        tableContext.reloadData()
//
//        return overlayScrollView
//    }
    
    override func menu(for menuKind: FIMenuKind) -> NSMenu? {
        
        // Produce a menu for the extension.

        if (menuKind == .contextualMenuForContainer)
        {
            let menu: NSMenu = baseMenu()
    
//          menu = addSeparatorTo(menu: menu)

            if #available(OSX 11.0, *) {
                
                let item: NSMenuItem = NSMenuItem(title: "New File Creation...", action: nil, keyEquivalent: "")
                item.image = NSImage(named: "Icon")
                menu.addItem(item)
                
                let subMenu: NSMenu = createSubMenus(menu: menu, item: item)
            
                return subMenu
                
            } else {
            
                let item: NSMenuItem = NSMenuItem(title: "New File Creation...", action: #selector(FinderSync.createNewFile(_:)), keyEquivalent: "")
                item.image = NSImage(named: "Icon")
                menu.addItem(item)

                return menu
            }
        }
        
        if (menuKind == .toolbarItemMenu)
        {
            let rows : [String] = self.createRows() as! [String]

            let menu = self.recreatePopUpMenu(rowsItem: rows, action: #selector(FinderSync.createNewFile(_:)))
            
            return menu
        }
        
        if (menuKind == .contextualMenuForItems)
        {
            let paths : [URL]? = FIFinderSyncController.default().selectedItemURLs()
            
            if (paths != nil) {
                
                if urlsAreFiles(paths: paths!) {
                    
                    let menu = NSMenu(title: "")
                    
                    let item: NSMenuItem = NSMenuItem(title: SMLocalizedString("add_as_template"), action: #selector(FinderSync.addAsTemplate(_:)), keyEquivalent: "")
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
    
    func recreatePopUpMenu(rowsItem : [String], action: Selector? = nil) -> NSMenu {
        
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
     
            let menuItemRow: NSMenuItem = NSMenuItem(title: rowString, action: action, keyEquivalent: "")
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
    
    // MARK: - NSTableViewDatasource & NSTableViewDelegate methods
    
//    func numberOfRows(in tableView: NSTableView) -> Int
//    {
//        return self.templates.count
//    }
//
//    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat
//    {
//        return CELL_HEIGHT
//    }
//
//    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
//    {
//        if tableColumn!.identifier.rawValue == "columnWindow1"
//        {
//            let cellView = NSView(frame: NSMakeRect(0, 0, tableView.frame.size.width, CELL_HEIGHT))
//            cellView.identifier = NSUserInterfaceItemIdentifier(rawValue: "row" + String(row))
//
//            let value : String = self.templates.object(at: row) as! String
//            SMLog("value " + value)
//
//            cellView.wantsLayer = true
//
//            if (row % 2 == 0)
//            {
//                cellView.layer?.backgroundColor = NSColor(calibratedRed: 224/255, green: 224/255, blue: 224/255, alpha: 1.0).cgColor
//            }
//            else
//            {
//                cellView.layer?.backgroundColor = NSColor.white.cgColor
//            }
//
//            let components : [String]? = value.components(separatedBy: ".") as [String]?
//
//            var image : NSImage = NSWorkspace.shared.icon(forFileType:"sh")
//
//            if (components != nil)
//            {
//                image = (components!.count > 1) ? NSWorkspace.shared.icon(forFileType: components![1]) : NSWorkspace.shared.icon(forFileType:"svg")
//            }
//
//            let imageView : NSImageView = NSImageView(frame: NSMakeRect(10, 0, 50, 50))
//            imageView.image = image
//
//            cellView.addSubview(imageView)
//
//            let textField : NSTextField = NSTextField(frame: NSMakeRect(80, 12, 270, 20))
//
//            textField.textColor = NSColor.black
//
//            var extensionFile : String = "sh"
//
//            if (components != nil)
//            {
//                extensionFile  = (components!.count > 1) ? components![1].uppercased() : extensionFile
//            }
//
//            textField.stringValue = NSString(format: SMLocalizedString("newFileMask") as NSString, extensionFile, value) as String
//            textField.alignment = NSTextAlignment.left
//            textField.font = NSFont.systemFont(ofSize: 12)
//            textField.isBezeled = false
//            textField.drawsBackground = false
//            textField.isEditable = false
//            textField.isSelectable = false
//            textField.backgroundColor = NSColor.clear
//            textField.wantsLayer = true
//            textField.layer?.backgroundColor = NSColor.clear.cgColor
//            textField.lineBreakMode = NSLineBreakMode.byWordWrapping
//            textField.usesSingleLineMode = true
//
//            cellView.addSubview(textField)
//
//            cellView.wantsLayer = true
//
//            return cellView
//        }
//
//        return nil
//    }
//
//
//    func tableViewSelectionDidChange(_ notification: Notification)
//    {
////        self.table.deselectRow(self.table.selectedRow)
//    }
//
//    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool
//    {
//        // set the pasteboard for HFS promises only
//        pboard.declareTypes([NSPasteboard.PasteboardType.filePromise], owner:self)
//
//        // the pasteboard must know the type of files being promised
//        let filenameExtensions : NSMutableArray = NSMutableArray()
//
//        // iterate the selected files in your NSArrayController and get the extension from each file,
//        // we're assuming that you store the file's filename in Core Data as an attribute
//        let selectedObjects : NSArray = self.templates.objects(at: rowIndexes) as NSArray
//
//        for file in selectedObjects as! [String]
//        {
//            let components : [String] = file.components(separatedBy: ".")
//
//            var extensionFile : String = "sh"
//
//            if (components.count > 1)
//            {
//                extensionFile = components[1] as String
//            }
//
//            if (extensionFile != "")
//            {
//                filenameExtensions.add(extensionFile)
//            }
//        }
//
//        // give the pasteboard the file extensions
//        pboard.setPropertyList(filenameExtensions, forType: NSPasteboard.PasteboardType.filePromise)
//
//        return true
//    }
//
//    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation
//    {
//        if dropOperation == .above
//        {
//            return .move
//        }
//
//        return NSDragOperation()
//    }
//
//    func isDirectory(pathURL: NSURL) -> Bool {
//
//        var isDirectory : ObjCBool = false
//        let fileExistsAtPath : Bool  = Foundation.FileManager.default.fileExists(atPath: pathURL.path!, isDirectory: &isDirectory)
//
//        if (fileExistsAtPath)
//        {
//            if (pathURL.pathExtension?.lowercased() == "rtfd")
//            {
//                // rtfd is a file
//                return false
//            }
//
//            if isDirectory.boolValue
//            {
//                // It's a Directory.
//                return true
//            }
//        }
//
//        return false
//    }
//
//    func addURLFile(fileURLItem: URL) {
//
//        let choosenFile : URL! = (fileURLItem as NSURL).filePathURL!
//
//        let pathString : String = choosenFile.resolvingSymlinksInPath().path
//
//        //                    let fileManager : NSFileManager = NSFileManager()
//        let finalPath : String = FileManager.applicationDirectory().appendingPathComponent(choosenFile.lastPathComponent)
//
//        var exists : Bool = false
//
//        for item in FileManager.listTemplates()
//        {
//            let itemStr : String = item as! String
//
//            if (NSURL(fileURLWithPath: itemStr).lastPathComponent!.lowercased() == NSURL(fileURLWithPath: finalPath).lastPathComponent!.lowercased())
//            {
//                exists = true
//                break
//            }
//        }
//
//        if exists
//        {
//            SMLog("plantilla ya existe")
//
////            SMObject.showModalAlert(SMLocalizedString("warning"), message: SMLocalizedString("templateExists"))
//        }
//        else
//        {
//            _ = FileManager.copyNewTemplateFileToApplicationSupport(pathString)
//
//            SMLog("path: " + pathString)
//
//            let dict : NSMutableDictionary = NSMutableDictionary()
//
//            dict.setObject(1, forKey: "enableColumn" as NSCopying)
//            dict.setObject(1, forKey: "active" as NSCopying)
//
//            let tempURL : URL = URL(fileURLWithPath: pathString)
//            dict.setObject(tempURL.lastPathComponent, forKey: "templateColumn" as NSCopying)
//
//            let templatesArray : NSMutableArray = NSMutableArray(array: Preferences.loadTemplatesTablePreferences())
//
//            templatesArray.add(dict)
//
//            _ = Preferences.setTemplatesTablePreferences(templatesArray)
//
//            self.templates = NSMutableArray(array: self.obtainRows())
//
//            self.tableContext.reloadData()
//
//            if (self.templates.count > 0)
//            {
//                self.tableContext.scrollRowToVisible(self.templates.count - 1)
//            }
//
//            SCHEDULE_POSTNOTIFICATION(kUpdateTableFromPreferences, object: nil)
//        }
//    }
//
//    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool
//    {
//        var oldIndexes = [Int]()
//
//        info.enumerateDraggingItems(options: [], for: tableView, classes: [NSPasteboardItem.self], searchOptions: [:]) { ( draggingItem: NSDraggingItem, idx: Int, stop: UnsafeMutablePointer<ObjCBool>) in
//
//            let pasteItem : NSPasteboardItem = (draggingItem.item as! NSPasteboardItem)
//            let strIndex: String? = pasteItem.string(forType: NSPasteboard.PasteboardType(rawValue: "public.data"))
//
//            if (strIndex != nil)
//            {
//                if let index = Int(strIndex!)
//                {
//                    oldIndexes.append(index)
//                }
//            }
//            //            else
//            //            {
//            //                let path = pasteItem.string(forType: NSPasteboard.PasteboardType(rawValue: "public.file-url"))
//            //            let url : NSURL = NSURL(fileURLWithPath: path!)
//            //            print("\(url.absoluteString!)")
//
//            //                let pb: NSPasteboard = info.draggingPasteboard()
//
//            //list the file type UTIs we want to accept
//            //                NSArray* acceptedTypes = [NSArray arrayWithObject:"public.file-url"];
//
//            //                let filteringOptions = [NSPasteboard.ReadingOptionKey.urlReadingContentsConformToTypes:"public.file-url"]
//            //
//            //                let arrayURLs: NSArray = pb.readObjects(forClasses: [NSURL.self], options: filteringOptions)! as NSArray
//            //                print("cocunt urls: \(arrayURLs.count)")
//            //                NSArray* urls = [pb readObjectsForClasses:[NSArray arrayWithObject:[NSURL class]]
//            //                    options:[NSDictionary dictionaryWithObjectsAndKeys:
//            //                    [NSNumber numberWithBool:YES],NSPasteboardURLReadingFileURLsOnlyKey,
//            //                    acceptedTypes, NSPasteboardURLReadingContentsConformToTypesKey,
//            //                    nil]];
//            //            }
//        }
//        //        info.enumerateDraggingItems(options: [], for: tableView, classes: [NSPasteboardItem.self], searchOptions: [:]) {
//        //
//        //            if let index = Int((($0.0.item as! NSPasteboardItem).string(forType: "public.data"))!)
//        //            {
//        //                oldIndexes.append(index)
//        //            }
//        //        }
//
//        if (oldIndexes.count == 0)
//        {
//            let pb: NSPasteboard = info.draggingPasteboard
//
//            let filteringOptions : [NSPasteboard.ReadingOptionKey : Any] = [NSPasteboard.ReadingOptionKey.urlReadingFileURLsOnly : NSNumber.init(booleanLiteral: true)]
//
//            let arrayURLs: NSArray = pb.readObjects(forClasses: [NSURL.self as AnyClass], options: filteringOptions)! as NSArray
//            SMLog("count urls: \(arrayURLs.count)")
//
//            for itemURL in arrayURLs {
//
//                let url: NSURL = itemURL as! NSURL
//
//                if (!self.isDirectory(pathURL: url)) {
//
//                    self.addURLFile(fileURLItem: URL(fileURLWithPath: url.path!))
//                }
//
//                SMLog("url path: \(String(describing: url.path))")
//            }
//        }
//        else
//        {
//            var oldIndexOffset = 0
//            var newIndexOffset = 0
//
//            // For simplicity, the code below uses `tableView.moveRowAtIndex` to move rows around directly.
//            // You may want to move rows in your content array and then call `tableView.reloadData()` instead.
//            tableView.beginUpdates()
//
//            for oldIndex in oldIndexes
//            {
//                if oldIndex < row
//                {
//                    let finalOldIndex : Int = oldIndex + oldIndexOffset
//                    let finalNewIndex : Int = row - 1
//
//                    tableView.moveRow(at: finalOldIndex, to: finalNewIndex)
//                    oldIndexOffset -= 1
//
//                    SMLog("old index: \(finalOldIndex) new index: \(finalNewIndex)")
//
//                    let object : NSMutableDictionary = templates[finalOldIndex] as! NSMutableDictionary
//
//                    let tempArray : NSMutableArray = NSMutableArray(array: Preferences.loadTemplatesTablePreferences())
//
//                    let originalNewIndex : Int = tempArray.index(of: templates[finalNewIndex] as! NSMutableDictionary)
//                    let originalOldIndex : Int = tempArray.index(of: templates[finalOldIndex] as! NSMutableDictionary)
//
//                    tempArray.removeObject(at: originalOldIndex)
//                    tempArray.insert(object, at: originalNewIndex)
//
//                    _ = Preferences.setTemplatesTablePreferences(tempArray)
//
//                    templates.removeObject(at: finalOldIndex)
//                    templates.insert(object, at: finalNewIndex)
//                }
//                else
//                {
//                    let finalOldIndex : Int = oldIndex
//                    let finalNewIndex : Int = row + newIndexOffset
//
//                    tableView.moveRow(at: finalOldIndex, to: finalNewIndex)
//                    newIndexOffset += 1
//                    SMLog("old index: \(finalOldIndex) new index: \(finalNewIndex)")
//
//                    let object : NSMutableDictionary = templates[finalOldIndex] as! NSMutableDictionary
//
//                    let tempArray : NSMutableArray = NSMutableArray(array: Preferences.loadTemplatesTablePreferences())
//
//                    let originalNewIndex : Int = tempArray.index(of: templates[finalNewIndex] as! NSMutableDictionary)
//                    let originalOldIndex : Int = tempArray.index(of: templates[finalOldIndex] as! NSMutableDictionary)
//
//                    tempArray.removeObject(at: originalOldIndex)
//                    tempArray.insert(object, at: originalNewIndex)
//
//                    _ = Preferences.setTemplatesTablePreferences(tempArray)
//
//                    templates.removeObject(at: finalOldIndex)
//                    templates.insert(object, at: finalNewIndex)
//                }
//            }
//
//            tableView.endUpdates()
//        }
//
//        tableView.reloadData()
//
//        SCHEDULE_POSTNOTIFICATION(kUpdateTableFromPreferences, object: nil)
//
//        return true
//    }
//
//    func tableView(_ tableView: NSTableView, namesOfPromisedFilesDroppedAtDestination dropDestination: URL, forDraggedRowsWith indexSet: IndexSet) -> [String]
//    {
//        // return of the array of file names
//        let draggedFilenames : NSMutableArray = NSMutableArray()
//
//        // iterate the selected files
//        let selectedObjects : NSArray = self.templates.objects(at: indexSet) as NSArray
//
//        for file in selectedObjects as! [String]
//        {
//            draggedFilenames.add(file)
//
//            let source : String = FileManager.resolvePathForFile(file)
//
//            var destination : String = dropDestination.appendingPathComponent(file, isDirectory: false).path
////            var destination : String = dropDestination.path!.stringByAppendingPathComponent(file)
//
//            SMLog("destPath " + destination)
//
//            if FileManager.copyFile(from: source, destination: &destination, file: file)
//            {
//                SMLog("copied")
//
//                if (Preferences.loadOpenFileOnCreation())
//                {
//                    Utils.openFile(destination)
//                }
//
//                if (Preferences.loadRevealInFinder())
//                {
//                    Utils.revealInFinder(destination)
//                }
//            }
//
////            if (Preferences.loadHidePopup())
////            {
////                closePopUpController()
////            }
//
//            if (Preferences.loadActiveSound())
//            {
//                NSSound(named: "dropped")?.play()
//            }
//        }
//
////        REGISTER_DISTRIBUTED_NOTIFICATION(self, selector: #selector(AppDelegate.eventFinderExtensionNotification(_:)), name: kFinderExtensionUpdate)
//
//        return draggedFilenames as NSArray as! [String]
//    }
}
