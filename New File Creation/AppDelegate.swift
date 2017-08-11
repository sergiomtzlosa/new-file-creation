//
//  AppDelegate.swift
//  New File Creation
//
//  Created by sid on 04/08/15.
//  Copyright (c) 2015 com.sergiomtzlosa.filecreation. All rights reserved.
//

import Cocoa
import ServiceManagement
import QuartzCore

let kFileName = "NewFile"

let CELL_HEIGHT : CGFloat = 50

let kLoginHelperDekstopBundleIdentifier = "com.sergiomtzlosa.filecreationhelper"

let kFocusedAdvancedControlIndex = "FocusedAdvancedControlIndex"

@available(OSX 10.12.2, *)
fileprivate extension NSTouchBarItemIdentifier {
    
    static let customViewIdentifier = NSTouchBarItemIdentifier("com.sergiomtzlosa.filecreation.touchbar.items.customView")
    
    static let identifierCustom = NSTouchBarItemIdentifier("com.sergiomtzlosa.filecreation.touchbar.customTouchBar")
}

@available(OSX 10.12.2, *)
fileprivate extension NSTouchBarCustomizationIdentifier {
    
    static let mainTouchBarIdentifier = NSTouchBarCustomizationIdentifier("com.sergiomtzlosa.filecreation.touchbar.main.touchbar")
}

@NSApplicationMain
class AppDelegate: SMObject, NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate, WOMMenuletDelegateImages, NSTouchBarDelegate, NSOpenSavePanelDelegate
{
//    @IBOutlet weak var window: NSWindow!

    @IBOutlet var helpWindowExtension: NSWindow!
    
    var customViewTouchbar : NSView!
    var popupButton : NSPopUpButton!
    var appSettings : NSDictionary!
    var templates : NSArray!
    var isShowing : Bool?
    var savePanel : NSSavePanel!
    var table : NSTableView!
    var controller : WOMController!
    var dataFiles : NSArray = []
    var checkBox : NSButton!
    var darkModeOn : Bool!
    var preferencesWindowController : MASPreferencesWindowController!
    var focusedAdvancedControlIndex: NSInteger {
        
        get {
            return UserDefaults.standard.integer(forKey: kFocusedAdvancedControlIndex)
        }
        
        set {

            UserDefaults.standard.set(focusedAdvancedControlIndex, forKey:kFocusedAdvancedControlIndex)
        }
    }
    
    class func preferencesWindow() -> NSWindow
    {
        return AppDelegate.sharedInstance().preferencesWindowController.window!
    }
    
    override class func sharedInstance() -> AppDelegate
    {
        return NSApplication.shared().delegate as! AppDelegate
    }
    
    class func isDarkMode() -> Bool
    {
        return AppDelegate.sharedInstance().observerDarkMode()
    }
    
    override func awakeFromNib()
    {
//        super.windowObject = window
        
        REGISTER_NOTIFICATION(self, selector: #selector(AppDelegate.eventUpdateTableFromPreferences(_:)), name: kUpdateTableFromPreferences)

        if !Preferences.loadFirstBoot()
        {
            lightVibrantWindow(helpWindowExtension)
            helpWindowExtension.center()
            helpWindowExtension.orderFrontRegardless()
            helpWindowExtension.makeKeyAndOrderFront(nil)
        
            _ = Preferences.activeSound(true)
            _ = Preferences.useRevealInFinder(false)
            _ = Preferences.openFileOnCreation(false)
            _ = Preferences.setFirstBoot(true);
            
            Preferences.setDefaultValues()
        }
        
        if (!Preferences.defaultsContainsKey("templatesTablePreferences"))
        {
            Preferences.setDefaultValues()
        }
        
        if (Preferences.readPlistApplicationPreferences() == nil)
        {
            _ = Preferences.activeSound(true)
            _ = Preferences.useRevealInFinder(false)
            _ = Preferences.openFileOnCreation(false)
        }

        self.templates = obtainRows()
        self.isShowing = false
        
        createPreferencesWindowController()
        _ = observerDarkMode()
        
        self.controller = WOMController()
        self.controller.menulet.imagesDelegate = self

        REGISTER_NOTIFICATION(self, selector: #selector(AppDelegate.eventLoadPopUp(_:)), name: kPopOverDidLoad)
        REGISTER_NOTIFICATION(self, selector: #selector(AppDelegate.eventFinderSync(_:)), name: kFinderSyncOption)

        self.dataFiles = NSArray(array:extractFiles())
        
        let 👿 : Bool = self.launchOnLogin()
        SMLog("is lanch a start: " + (👿 ? "YES" : "NO"))
        
        REGISTER_DISTRIBUTED_NOTIFICATION(self, selector: #selector(AppDelegate.eventNotifyDarkModeChanged(_:)), name: kChangeInterfaceNotification)
        
        REGISTER_DISTRIBUTED_NOTIFICATION(self, selector: #selector(AppDelegate.eventNotifySuspend(_:)), name: NSNotification.Name.NSWindowDidResignKey.rawValue)

        super.awakeFromNib()
    }
    
    func changeValuePopUpButton(_ sender: AnyObject)
    {
        if let pub = sender as? NSPopUpButton
        {
            SMLog(pub.titleOfSelectedItem as String!)
            SMLog(pub.indexOfSelectedItem)
            
            let templateFile : String = self.templates[pub.indexOfSelectedItem] as! String
            
            var split : [String] = templateFile.components(separatedBy: ".")
            let extensionString : String = split[1]
            
            SMLog("templateFile " + templateFile)
            SMLog("extensionString " + extensionString)
            
            savePanel.allowedFileTypes = [extensionString]
            savePanel.nameFieldStringValue = "NewFile." + extensionString
        }
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
    
    func doubleClick(_ object : AnyObject) {
    
        if (!Preferences.loadDoubleClick())
        {
            return
        }
        
        let rowNumber : NSInteger = table.clickedRow
        
        if (dataFiles.count > 0)
        {
            let item : String = dataFiles[rowNumber] as! String
            
            let sourcePathFile : String = FileManager.resolvePathForFile(item)
            
            SMLog("source: " + sourcePathFile)
            
            if (Preferences.loadHidePopup())
            {
                closePopUpController()
            }

            DispatchQueue.main.async(execute: {
            
                self.launchSavePanel(sourcePathFile)
            })
        }
    }
    
    func launchSavePanel(_ sourceFile : String)
    {
        NSApp.activate(ignoringOtherApps: true)
        
        if isShowing == true
        {
            return
        }
        
        self.isShowing = true
        
        let desktopPath : String = (NSSearchPathForDirectoriesInDomains(Foundation.FileManager.SearchPathDirectory.desktopDirectory, Foundation.FileManager.SearchPathDomainMask.userDomainMask, true) as NSArray).object(at: 0) as! String
        
        let target = URL(fileURLWithPath: desktopPath)
        
        self.savePanel = NSSavePanel()
        
        let templateFile : String = URL(fileURLWithPath: sourceFile).lastPathComponent
        var split : [String] = templateFile.components(separatedBy: ".")
        let extensionString : String = split[1]
        
        self.savePanel.nameFieldStringValue = kFileName + "." + extensionString
        self.savePanel.becomeFirstResponder()
        self.savePanel.title = SMLocalizedString("saveNewFileAs")
        self.savePanel.showsTagField = false
        self.savePanel.showsHiddenFiles = false
        self.savePanel.showsToolbarButton = true
        self.savePanel.canCreateDirectories = true
        self.savePanel.becomeMain()
        self.savePanel.level = 0//Int(CGWindowLevelKey(key: CGWindowLevelKey.ModalPanelWindowLevelKey)?.rawValue)
        self.savePanel.showsResizeIndicator = false
        self.savePanel.disableSnapshotRestoration()
        self.savePanel.isExtensionHidden = false
        self.savePanel.allowedFileTypes = nil
        self.savePanel.center()
        
        NSApp.mainWindow?.makeKeyAndOrderFront(self.savePanel)
        
        let destination : URL = target
        
        self.savePanel.directoryURL = destination
        self.savePanel.isAutodisplay = true
//        let result : NSInteger = self.savePanel.runModal()
        var error : NSError?
        
        if (error != nil)
        {
            SMLog(error!.localizedDescription)
            NSApp.presentError(error!)
            
            self.isShowing = false
            
            return
        }
        
        self.savePanel.begin { ( result :Int) in
            
            if (result == NSFileHandlingPanelCancelButton)
            {
                self.isShowing = false
            }
            
            if (result == NSFileHandlingPanelOKButton)
            {
                let valueFile : String = URL(fileURLWithPath: sourceFile).lastPathComponent
                //var components : [String] = valueFile.componentsSeparatedByString(".") as [String]
                
                //var extensionFile : String = components[1].lowercaseString
                
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
                        NSSound(named: "dropped")?.play()
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
                    SMLog("error: " + error!.localizedDescription)
                }
                
                self.isShowing = false
            }
        }
    }
    
    func extractFiles() -> NSArray
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
    
    func lightVibrantWindow(_ window: NSWindow)
    {
        window.appearance = NSAppearance(named: NSAppearanceNameVibrantLight)
        
        let visualEffectView = NSVisualEffectView(frame: NSMakeRect(0, 0, window.frame.width, window.frame.height))
        visualEffectView.material = NSVisualEffectMaterial.light
        visualEffectView.blendingMode = NSVisualEffectBlendingMode.behindWindow
        visualEffectView.state = NSVisualEffectState.active
        
        window.styleMask = NSWindowStyleMask.fullSizeContentView
        window.titlebarAppearsTransparent = true

        window.contentView!.addSubview(visualEffectView, positioned: NSWindowOrderingMode.below, relativeTo: nil)
        window.contentView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[visualEffectView]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["visualEffectView":visualEffectView]))
        window.contentView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[visualEffectView]-0-|", options: NSLayoutFormatOptions(), metrics: nil, views: ["visualEffectView":visualEffectView]))
    }
    
    func launchOnLogin() -> Bool
    {
        return AgentController.checkLogin(forIdentifier: kLoginHelperDekstopBundleIdentifier)
    }
    
    func checkBoxAction(_ 😎 : AnyObject)
    {
        let checkButton : NSButton = 😎 as! NSButton
        
        if (checkButton.state == NSOnState)
        {
            SMLog("on")
        }
        else
        {
            SMLog("off")
        }
        
        if (checkButton.state == NSOnState)
        {
            _ = Preferences.wantsLaunchAtLogin(true)
        }
        else
        {
            _ = Preferences.wantsLaunchAtLogin(false)
        }
    
        if (checkButton.state == NSOnState)
        {
            // ON
            // Turn on launch at login
            if (!AgentController.enableLoginItem(forIdentifier: kLoginHelperDekstopBundleIdentifier, forStatus: true))
            {
                SMLog("Couldn't add Helper App to launch at login item list.")
            }
        }
        
        if (checkButton.state == NSOffState)
        {
            // OFF
            // Turn off launch at login
            if (!AgentController.enableLoginItem(forIdentifier: kLoginHelperDekstopBundleIdentifier, forStatus: false))
            {
                SMLog("Couldn't remove Helper App from launch at login item list.")
            }
        }
    }
    
    func closeApplication(_ sender: AnyObject)
    {
        NSApplication.shared().terminate(self)
    }
    
    func createPreferencesWindowController()
    {
        if (preferencesWindowController == nil)
        {
            let generalViewController : NSViewController = GeneralPreferencesViewController(nibName: "GeneralPreferencesView", bundle: nil)!

            let advancedViewController : NSViewController = FilesPreferencesViewController(nibName: "FilesPreferencesViewController", bundle: nil)!
            
            REGISTER_NOTIFICATION(advancedViewController, selector: Selector(("eventUpdateSettingsCloud:")), name: kUpdateSettingCloud)
            
            let cloudViewController : NSViewController = CloudSyncViewController(nibName: "CloudSyncViewController", bundle: nil)!
            
            let helpViewController : NSViewController = HelpPreferencesViewController(nibName: "HelpPreferencesViewController", bundle: nil)!
            
            var controllers : NSArray? = NSArray(objects: generalViewController, advancedViewController, cloudViewController, helpViewController)
            
            if #available(OSX 10.12.2, *) {
                
                let touchBarViewController : NSViewController = TouchBarPreferencesViewController(nibName: "TouchBarPreferencesViewController", bundle: nil)!
                
                controllers = NSArray(objects: generalViewController, advancedViewController, cloudViewController, touchBarViewController, helpViewController)
            }
         
            preferencesWindowController = MASPreferencesWindowController(viewControllers: controllers! as [AnyObject] , title:SMLocalizedString("settings"))
            
            let button = preferencesWindowController.window!.standardWindowButton(NSWindowButton.zoomButton)
            button?.isEnabled = false
        }
    }
    
    func showWindowPreferences()
    {
        if (controller != nil)
        {
            controller.closePopover()
        }
        
        createPreferencesWindowController()
        
        preferencesWindowController.showWindow(nil)
    }
    
    func showPreferences(_ sender: AnyObject)
    {
        closePopUpController()
        
        showWindowPreferences()
        preferencesWindowController.selectedViewController = preferencesWindowController.viewController(forIdentifier: SMLocalizedString("general"))
    }
    
    func closePopUpController()
    {
        if (controller != nil)
        {
            controller.closePopover()
        }
    }
    
    func createCustomView() -> NSView
    {
        let customView : NSView = NSView(frame: NSMakeRect(0, 0, 364, 425))
        customView.appearance = NSAppearance(named: NSAppearanceNameAqua)

        let buttonClose : NSButton = NSButton(frame: NSMakeRect(27, 350, 150, 40))
        
        buttonClose.title = SMLocalizedString("exitApp")
        buttonClose.setButtonType(NSButtonType.momentaryPushIn)
        buttonClose.bezelStyle = NSBezelStyle.rounded
        buttonClose.target = self
        buttonClose.action = #selector(AppDelegate.closeApplication(_:))
        
        customView.addSubview(buttonClose)
        
        let buttonPreferences : NSButton = NSButton(frame: NSMakeRect(188, 350, 150, 40))
        
        buttonPreferences.title = SMLocalizedString("settings")
        buttonPreferences.setButtonType(NSButtonType.momentaryPushIn)
        buttonPreferences.bezelStyle = NSBezelStyle.rounded
        buttonPreferences.target = self
        buttonPreferences.action = #selector(AppDelegate.showPreferences(_:))
        
        customView.addSubview(buttonPreferences)
        
        checkBox = NSButton(frame: NSMakeRect(10, 390, 240, 40))
        
        checkBox.target = self
        checkBox.action = #selector(AppDelegate.checkBoxAction(_:))
        checkBox.setButtonType(NSButtonType.switch)
        checkBox.state = (Preferences.isLaunchedAtLogin() ? NSOnState : NSOffState)
        checkBox.setNeedsDisplay()
        checkBox.attributedTitle = createAttributeStringForButton(SMLocalizedString("launchLogin"))
        customView.addSubview(checkBox)
        
        let helpButton : NSButton = NSButton()
        
        helpButton.title = ""
        helpButton.frame = CGRect(x: 325, y: 388, width: 40, height: 40)
        helpButton.bezelStyle = NSBezelStyle.helpButton;
        helpButton.target = self;
        helpButton.action = #selector(AppDelegate.showHelpAttached(_:))
        
        customView.addSubview(helpButton)
        
        let overlayScrollView : SMScrollView = SMScrollView(frame: NSMakeRect(0, 0, customView.frame.width, 350))

        overlayScrollView.verticalLineScroll = 1.0
        overlayScrollView.verticalPageScroll = 1.0
        overlayScrollView.hasVerticalScroller = true
        overlayScrollView.backgroundColor = NSColor.clear
        overlayScrollView.scrollerStyle = NSScrollerStyle.overlay
        overlayScrollView.hasHorizontalScroller = false
        overlayScrollView.drawsBackground = false
        overlayScrollView.pageScroll = overlayScrollView.contentSize.height
        overlayScrollView.scrollerKnobStyle = NSScrollerKnobStyle.dark
        overlayScrollView.wantsLayer = true
        
        table = NSTableView(frame: NSMakeRect(-1, 0, overlayScrollView.frame.size.width + 1, overlayScrollView.frame.height))
        
        table.target = self;
        table.doubleAction = #selector(AppDelegate.doubleClick(_:));

        table.selectionHighlightStyle = NSTableViewSelectionHighlightStyle.none
        table.layer?.cornerRadius = 0
        table.layer?.borderColor = NSColor.clear.cgColor
        table.headerView = nil
        table.layer?.backgroundColor = NSColor.clear.cgColor
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = NSColor.clear
        
        //Registering dragged Types
        table.register(forDraggedTypes: [NSFilenamesPboardType])
        
        //To support across application passing NO
        table.setDraggingSourceOperationMask(NSDragOperation.copy, forLocal: false)
       
        let column1 : NSTableColumn = NSTableColumn(identifier: "column1")
        
        column1.width = customView.frame.size.width - 2
        column1.resizingMask = NSTableColumnResizingOptions.autoresizingMask
        
        table.addTableColumn(column1)
   
        overlayScrollView.documentView = table
        customView.addSubview(overlayScrollView)
        
        table.columnAutoresizingStyle = NSTableViewColumnAutoresizingStyle.uniformColumnAutoresizingStyle
        column1.resizingMask = NSTableColumnResizingOptions.autoresizingMask
        table.sizeLastColumnToFit()
        
        table.reloadData()
        
        return customView
    }
    
    func showHelpAttached(_ sender: AnyObject)
    {
        showWindowPreferences()
        preferencesWindowController.selectedViewController = preferencesWindowController.viewController(forIdentifier: SMLocalizedString("help"))
    }
    
    func createHelpView() -> NSTextView
    {
        let textView : NSTextView = NSTextView(frame: CGRect.zero)
        
        textView.maxSize = NSMakeSize(CGFloat.greatestFiniteMagnitude, CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = true
        textView.autoresizingMask = NSAutoresizingMaskOptions.viewWidthSizable
        textView.textContainer?.widthTracksTextView = true
        textView.string = SMLocalizedString("dragAndDropItems")
        textView.backgroundColor = NSColor.clear
        textView.textColor = NSColor.white
        
        let size : NSRect  = SMObject.calculateSizeForText(textView.string! as NSString, textView: textView)
        
        textView.frame = size
        
        return textView
    }
    
    func createAttributeStringForButton(_ title : String) -> NSAttributedString
    {
        let color : NSColor = (darkModeOn!) ? NSColor.white : NSColor.black

        let attrTitle = NSMutableAttributedString(string: title)
        
        attrTitle.addAttribute(NSFontAttributeName, value: NSFont(name: "Helvetica", size: 13.0)!, range: NSMakeRange(0, attrTitle.length))
        attrTitle.addAttribute(NSForegroundColorAttributeName, value: color, range: NSMakeRange(0, attrTitle.length))

        return attrTitle
    }
    
    // MARK: - NSTableViewDatasource & NSTableViewDelegate methods
    
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return self.dataFiles.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat
    {
        return CELL_HEIGHT
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        if tableColumn!.identifier == "column1"
        {
            let
            cellView = NSView(frame: NSMakeRect(0, 0, tableView.frame.size.width, CELL_HEIGHT))
            cellView.identifier = "row" + String(row)
            
            let value : String = self.dataFiles.object(at: row) as! String
            SMLog("value " + value)
            
            cellView.wantsLayer = true
            
            if (row % 2 == 0)
            {
                cellView.layer?.backgroundColor = NSColor(calibratedRed: 224/255, green: 224/255, blue: 224/255, alpha: 1.0).cgColor
            }
            else
            {
                cellView.layer?.backgroundColor = NSColor.white.cgColor
            }

            var components : [String] = value.components(separatedBy: ".") as [String]
            
            let image : NSImage = NSWorkspace.shared().icon(forFileType: components[1])
          
            let imageView : NSImageView = NSImageView(frame: NSMakeRect(10, 0, 50, 50))
            imageView.image = image
            
            cellView.addSubview(imageView)
            
            let textField : NSTextField = NSTextField(frame: NSMakeRect(80, 12, 270, 20))
        
            textField.textColor = NSColor.black
            
            let extensionFile : String = components[1].uppercased()
            
            textField.stringValue = NSString(format: SMLocalizedString("newFileMask") as NSString, extensionFile, value) as String
            textField.alignment = NSTextAlignment.left;
            textField.font = NSFont.systemFont(ofSize: 12)
            textField.isBezeled = false
            textField.drawsBackground = false
            textField.isEditable = false
            textField.isSelectable = false
            textField.backgroundColor = NSColor.clear
            textField.wantsLayer = true
            textField.layer?.backgroundColor = NSColor.clear.cgColor
            textField.lineBreakMode = NSLineBreakMode.byWordWrapping
            textField.usesSingleLineMode = true
            
            cellView.addSubview(textField)
            
            cellView.wantsLayer = true

            return cellView
        }
        
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification)
    {
//        self.table.deselectRow(self.table.selectedRow)
    }
  
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool
    {
        // set the pasteboard for HFS promises only
        pboard.declareTypes(NSArray(object: NSFilesPromisePboardType) as! [String], owner:self)
        
        // the pasteboard must know the type of files being promised
        let filenameExtensions : NSMutableArray = NSMutableArray()
        
        // iterate the selected files in your NSArrayController and get the extension from each file,
        // we're assuming that you store the file's filename in Core Data as an attribute
        let selectedObjects : NSArray = self.dataFiles.objects(at: rowIndexes) as NSArray
 
        for file in selectedObjects as! [String]
        {
            var components : [String] = file.components(separatedBy: ".")
            let extensionFile : String = components[1] as String
            
            if (extensionFile != "")
            {
                filenameExtensions.add(extensionFile)
            }
        }
        
        // give the pasteboard the file extensions
        pboard.setPropertyList(filenameExtensions, forType: NSFilesPromisePboardType)
        
        return true
    }
    
    func tableView(_ tableView: NSTableView, namesOfPromisedFilesDroppedAtDestination dropDestination: URL, forDraggedRowsWith indexSet: IndexSet) -> [String]
    {
        // return of the array of file names
        let draggedFilenames : NSMutableArray = NSMutableArray()
        
        // iterate the selected files
        let selectedObjects : NSArray = self.dataFiles.objects(at: indexSet) as NSArray
    
        for file in selectedObjects as! [String]
        {
            draggedFilenames.add(file)

            let source : String = FileManager.resolvePathForFile(file)
        
            var destination : String = dropDestination.appendingPathComponent(file, isDirectory: false).path
//            var destination : String = dropDestination.path!.stringByAppendingPathComponent(file)
        
            SMLog("destPath " + destination)

            if FileManager.copyFile(from: source, destination: &destination, file: file)
            {
                SMLog("copied")
                
                if (Preferences.loadOpenFileOnCreation())
                {
                    Utils.openFile(destination)
                }
                
                if (Preferences.loadRevealInFinder())
                {
                    Utils.revealInFinder(destination)
                }
            }
            
            if (Preferences.loadHidePopup())
            {
                closePopUpController()
            }
            
            if (Preferences.loadActiveSound())
            {
                NSSound(named: "dropped")?.play()
            }
        }
        
        return draggedFilenames as NSArray as! [String]
    }
    
    func observerDarkMode() -> Bool
    {
//        let dict : NSDictionary = NSUserDefaults.standardUserDefaults().persistentDomainForName(NSGlobalDomain)!
//        var style : AnyObject? = dict.objectForKey("AppleInterfaceStyle")
        
        let appearance : String = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
        darkModeOn = (appearance.lowercased() == "dark") ? true : false
        
        if darkModeOn == false
        {
            SMLog("dark mode");
        }
        else
        {
            SMLog("light mode");
        }

        return darkModeOn
    }
    
    //MARK: - NSNotification methods
    
    func eventUpdateTableFromPreferences(_ notification : Notification)
    {
        DispatchQueue.main.async(execute: {
            
            SMLog("llega eventUpdateTableFromPreferences")
            SMLog("pasa eventUpdateTableFromPreferences1")
            let items : NSArray = NSArray(array: self.extractFiles())
            SMLog("pasa eventUpdateTableFromPreferences2")
            self.dataFiles = NSArray(array:items)
            SMLog("pasa eventUpdateTableFromPreferences3")
            self.table.reloadData()
            SMLog("pasa eventUpdateTableFromPreferences4")
            
            if #available(OSX 10.12.2, *) {

                SMLog("refresca");
                self.reloadTouchBar()
            }
        })
    }
    
    func eventFinderSync(_ notification : Notification)
    {
        SMLog("llega eventFinderSync")
    }
    
    func eventLoadPopUp(_ notification : Notification)
    {
        //var controller : WOMPopoverController = notification.object as! WOMPopoverController
        
        let customViewPopOver : NSView = createCustomView()
        
        self.controller.viewController.view.addSubview(customViewPopOver)

        SMLog("llega final")
    }
    
    func eventNotifyDarkModeChanged(_ notification : Notification)
    {
//        SMLog("notification: %@", notification.object)

        if (!self.controller.isActive)
        {
            return
        }
        
        if (observerDarkMode())
        {
            if controller != nil
            {
                controller.viewController.popover.appearance = NSAppearance(named: NSAppearanceNameVibrantDark)
            }
        }
        else
        {
            if controller != nil
            {
                controller.viewController.popover.appearance = NSAppearance(named: NSAppearanceNameVibrantLight)
            }
        }

        if (checkBox != nil)
        {
            checkBox.attributedTitle = createAttributeStringForButton("Launch at login")
        }
    }
    
    //MARK: - WOMMenuletDelegateImages delegate methods
    
    func activeImageName() -> String!
    {
        if (observerDarkMode())
        {
            return "icon-menulet-white"
        }
        
        return "icon-menulet"
    }
    
    func inactiveImageName() -> String!
    {
        if (observerDarkMode())
        {
            return "icon-menulet-white"
        }
        
        return "icon-menulet"
    }
    
    @IBAction func openSystemPreferences(_ sender: AnyObject) {
        
        Utils.openExtensionPreferences()
    }
   
    //MARK: - Other application methods
    
    override func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        super.applicationDidFinishLaunching(aNotification)

        if #available(OSX 10.12.2, *) {
            
            NSApplication.shared().isAutomaticCustomizeTouchBarMenuItemEnabled = true
            
            reloadTouchBar()
        }
    }
    
    override func applicationShouldTerminateAfterLastWindowClosed(_ theApplication: NSApplication) -> Bool
    {
        return super.applicationShouldTerminateAfterLastWindowClosed(theApplication)
    }
    
    func applicationWillTerminate(_ aNotification: Notification)
    {
        
    }
    
    func eventNotifySuspend(_ notification: Notification) {
        
        SMLog("llega")
    }
    
    //MARK: - NSTouchBarDelegate methods
    @available(OSX 10.12.2, *)
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItemIdentifier) -> NSTouchBarItem? {
        
        SMLog("touch bar identifier: \(identifier.rawValue)")
        
        if (identifier == .customViewIdentifier)
        {
            SMLog("aqui : touch bar entra")
            
            return createScrollView()
        }
        
        return nil
    }
    
    @available(OSX 10.12.2, *)
    func createScrollView() -> NSCustomTouchBarItem {
        
        let files : NSArray = NSArray(array: extractFiles())
        
        let widthButton = CGFloat(144)
        let heightButton = CGFloat(30)

        let viewButtons = NSView(frame: .zero)
        
        viewButtons.wantsLayer = true
        viewButtons.layer?.backgroundColor = .clear
 
        let scrollView : NSScrollView = NSScrollView(frame: .zero)
        
        scrollView.drawsBackground = false
        scrollView.backgroundColor = .clear
        scrollView.borderType = .noBorder
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = true
        scrollView.autoresizingMask = .viewWidthSizable

        let separator : CGFloat = 16
        var offset : CGFloat = 0
        var position : Int = 0
        
        for item in files {
            
            var components : [String] = (item as AnyObject).components(separatedBy: ".") as [String]
            
            let extensionItem: String = components[1]

            var image : NSImage = NSWorkspace.shared().icon(forFileType: extensionItem)
            image = Utils.resize(image: image, w: 20, h: 20)
            
            let button : NSButton = makeButtonWithIdentifier(title: extensionItem.uppercased(), image: image)
            button.frame = NSMakeRect(offset, 0, widthButton, heightButton)
            button.tag = position
            
            viewButtons.addSubview(button)
            
            offset = offset + separator + widthButton
            position += 1
        }

        if (Preferences.fadeTouchbar() == true)
        {
            viewButtons.animator().alphaValue = 0
            
            NSAnimationContext.runAnimationGroup({ (context) -> Void in
                
                context.duration = 2.0
                viewButtons.animator().alphaValue = 1
                
            }, completionHandler: nil)
        }
        
        scrollView.documentView = viewButtons
        
        var rect = viewButtons.frame
        rect.size.height = heightButton
        rect.size.width += ((separator * CGFloat(files.count - 1)) + CGFloat(files.count) * widthButton)
        
        viewButtons.frame = rect
        scrollView.frame = rect
        scrollView.contentView.setBoundsSize(rect.size)
        scrollView.contentView.setFrameSize(rect.size)

        let customItem : NSCustomTouchBarItem = NSCustomTouchBarItem.init(identifier: .identifierCustom)
        
        customItem.view = scrollView
        
        return customItem
    }

    @available(OSX 10.12.2, *)
    func makeButtonWithIdentifier(title: String, image: NSImage) -> NSButton {
        
        var tempTitle = title
        
        if (Preferences.showTitleTouchBarButtons() == false)
        {
            tempTitle = "";
        }
        
        let button : NSButton = NSButton(title: tempTitle, image: image, target: self, action: #selector(createNewFile(sender:)))
        
        return button
    }
    
    func createNewFile(sender: NSButton) {
        
        SMLog("click touch bar entra: \(sender.title)")
        SMLog("click touch bar entra: \(sender.tag)")
        
        let indexButton : Int = sender.tag
        
        DispatchQueue.main.async(execute: {
            
            self.launchSavePanelTouchBar(index: indexButton)
        })
    }
    
    @available(OSX 10.12.2, *)
    func reloadTouchBar() {

        NSApp.touchBar = nil
        NSApp.touchBar = createTouchBar()
    }
    
    @available(OSX 10.12.2, *)
    func createTouchBar() -> NSTouchBar {
        
        let touchBar : NSTouchBar = NSTouchBar()
        
        touchBar.delegate = self
        touchBar.defaultItemIdentifiers = [.customViewIdentifier]
        touchBar.customizationAllowedItemIdentifiers = [.customViewIdentifier]
        touchBar.customizationIdentifier = .mainTouchBarIdentifier
        
        return touchBar
    }
    
    func launchSavePanelTouchBar(index : Int)
    {
        NSApp.activate(ignoringOtherApps: true)
        
        customViewTouchbar = newAccessoryView(index: index)
        
        if isShowing == true
        {
            return
        }
        
        self.isShowing = true
        
        let desktopPath : String = (NSSearchPathForDirectoriesInDomains(Foundation.FileManager.SearchPathDirectory.desktopDirectory, Foundation.FileManager.SearchPathDomainMask.userDomainMask, true) as NSArray).object(at: 0) as! String
        
        let target = URL(fileURLWithPath: desktopPath)
        
        self.savePanel = NSSavePanel()
        
        let templateFile : String = self.templates[index] as! String
        var split : [String] = templateFile.components(separatedBy: ".")
        let extensionString : String = split[1]
        
        self.savePanel.nameFieldStringValue = kFileName + "." + extensionString
        self.savePanel.becomeFirstResponder()
        self.savePanel.title = (currentLanguage() == "es") ? "Guardar nuevo archivo como..." : "Save new file as..."
        self.savePanel.showsTagField = false
        self.savePanel.showsHiddenFiles = false
        self.savePanel.showsToolbarButton = true
        self.savePanel.canCreateDirectories = true
        self.savePanel.accessoryView = self.customViewTouchbar
        self.savePanel.becomeMain()
        self.savePanel.level = 0//CGWindowLevelKey.ModalPanelWindowLevelKey
        self.savePanel.showsResizeIndicator = false
        self.savePanel.disableSnapshotRestoration()
        self.savePanel.isExtensionHidden = false
        self.savePanel.allowedFileTypes = nil
        self.savePanel.center()
        
        NSApp.mainWindow?.makeKeyAndOrderFront(self.savePanel)
        
        let destination : URL = target
        
        self.savePanel.directoryURL = destination
        self.savePanel.isAutodisplay = true
        
        self.savePanel.begin { ( result :Int) in
            
            var error : NSError?
            
            if result == NSFileHandlingPanelCancelButton {
                
                let rows : [String] = self.createRows() as! [String]
                
                self.popupButton.removeAllItems()
                self.popupButton.addItems(withTitles: rows)
                self.popupButton.selectItem(at: index)
                
                self.isShowing = false
            }
            
            if result == NSFileHandlingPanelOKButton {
                
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
                        NSSound(named: "dropped")?.play()
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
                self.popupButton.selectItem(at: index)
                
                self.isShowing = false
            }
        }
        
//        let result : NSInteger = self.savePanel.runModal()
//        var error : NSError?
//
//        if (error != nil)
//        {
//            SMLog(error!.localizedDescription)
//            NSApp.presentError(error!)
//
//            let rows : [String] = self.createRows() as! [String]
//
//            self.popupButton.removeAllItems()
//            self.popupButton.addItems(withTitles: rows)
//            self.popupButton.selectItem(at: index)
//            
//            self.isShowing = false
//            
//            return
//        }
//        
//        if (result == NSModalResponseCancel)
//        {
//            let rows : [String] = self.createRows() as! [String]
//            
//            self.popupButton.removeAllItems()
//            self.popupButton.addItems(withTitles: rows)
//            self.popupButton.selectItem(at: index)
//            
//            self.isShowing = false
//        }
//        
//        if (result == NSFileHandlingPanelOKButton)
//        {
//            let valueFile : String = self.templates[self.popupButton.indexOfSelectedItem] as! String
//            //var components : [String] = valueFile.componentsSeparatedByString(".") as [String]
//            
//            //let extensionFile : String = components[1].lowercaseString
//            
//            let source : String = FileManager.resolvePathForFile(valueFile)
//            let destination : String = (self.savePanel.url! as NSURL).filePathURL!.resolvingSymlinksInPath().path
//            
//            self.savePanel.directoryURL = URL(fileURLWithPath: destination)
//            
//            let fileManager = Foundation.FileManager.default
//            
//            if fileManager.fileExists(atPath: destination) {
//                
//                SMLog("archivo existe: \(destination)")
//                
//                do {
//                    try fileManager.removeItem(at: URL(fileURLWithPath: destination))
//                } catch let error1 as NSError {
//                    error = error1
//                    SMLog("error: \(error!.localizedDescription)")
//                } catch {
//                    SMLog("error")
//                }
//            }
//            
//            do {
//                
//                try Foundation.FileManager.default.copyItem(atPath: source, toPath: destination)
//                SMLog("copied")
//                
//                let soundEnabled : Int = self.appSettings.object(forKey: "soundEnabled") as! Int
//                
//                if (soundEnabled == 1)
//                {
//                    NSSound(named: "dropped")?.play()
//                }
//                
//                let openOncreation : Int = self.appSettings.object(forKey: "openOncreation") as! Int
//                
//                if (openOncreation == 1)
//                {
//                    Utils.openFile(destination)
//                }
//                
//                let revealOnCreation : Int = self.appSettings.object(forKey: "revealOnCreation") as! Int
//                
//                if (revealOnCreation == 1)
//                {
//                    Utils.revealInFinder(destination)
//                }
//            } catch let error1 as NSError {
//                error = error1
//                SMLog("error: \(error!.localizedDescription)")
//            } catch {
//                SMLog("error")
//            }
//            
//            let rows : [String] = self.createRows() as! [String]
//            
//            self.popupButton.removeAllItems()
//            self.popupButton.addItems(withTitles: rows)
//            self.popupButton.selectItem(at: index)
//            
//            self.isShowing = false
//        }
    }
    
    func newAccessoryView(index : Int) -> NSView?
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
        popupButton.selectItem(at: index)
        
        popupButton.action = #selector(changeValuePopUpButton(_:))
        popupButton.target = self
        
        accesoryView.addSubview(popupButton)
        
        return accesoryView
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
}
