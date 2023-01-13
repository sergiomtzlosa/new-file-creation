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

let kFinderExtensionUpdate = "FinderSynxNotificationNewFile"

@available(OSX 10.12.2, *)
fileprivate extension NSTouchBarItem.Identifier {
    
    static let customViewIdentifier = NSTouchBarItem.Identifier("com.sergiomtzlosa.filecreation.touchbar.items.customView")
}

@available(OSX 10.12.2, *)
fileprivate extension NSTouchBar.CustomizationIdentifier {
    
    static let mainTouchBarIdentifier = "com.sergiomtzlosa.filecreation.touchbar.main.touchbar"
}

@NSApplicationMain
class AppDelegate: SMObject, NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate, NSPopoverDelegate /*WOMMenuletDelegateImages*/, NSTouchBarDelegate, NSOpenSavePanelDelegate
{
//    @IBOutlet weak var window: NSWindow!

    @IBOutlet var helpWindowExtension: NSWindow!
    
    var fastWindow: NSWindow!
    
    var advancedViewController : FilesPreferencesViewController!

    var customViewTouchbar : NSView!
    var popupButton : NSPopUpButton!
    var appSettings : NSDictionary!
    var templates : NSArray!
    var isShowing : Bool?
    var savePanel : NSSavePanel!
    var table : NSTableView!
    var tableHUD : NSTableView!
    var controller : NSPopover! //WOMController!
    var statusItem : NSStatusItem!
    var dataFiles : NSMutableArray = []
    var checkBox : NSButton!
    var darkModeOn : Bool!
    var preferencesWindowController : MASPreferencesWindowController!
    var focusedAdvancedControlIndex: NSInteger {
        
        get {
            return UserDefaults.standard.integer(forKey: kFocusedAdvancedControlIndex)
        }
        
        set {
            //UserDefaults.standard.set(focusedAdvancedControlIndex, forKey:kFocusedAdvancedControlIndex)
            UserDefaults.standard.set(newValue, forKey:kFocusedAdvancedControlIndex)
        }
    }
    
    class func preferencesWindow() -> NSWindow
    {
        return AppDelegate.sharedInstance().preferencesWindowController.window!
    }
    
    override class func sharedInstance() -> AppDelegate
    {
        return NSApplication.shared.delegate as! AppDelegate
    }
    
    class func isDarkMode() -> Bool
    {
        return AppDelegate.sharedInstance().observerDarkMode()
    }
    
    override func awakeFromNib()
    {
       // super.windowObject = window
              
        REGISTER_DISTRIBUTED_NOTIFICATION(self, selector: #selector(AppDelegate.eventFinderExtensionNotification(_:)), name: kFinderExtensionUpdate)
        REGISTER_NOTIFICATION(self, selector: #selector(AppDelegate.eventUpdateTableFromPreferences(_:)), name: kUpdateTableFromPreferences)
        REGISTER_DISTRIBUTED_NOTIFICATION(self, selector: #selector(AppDelegate.eventAddFileFromExtensionFinder(_:)), name: kAddFileFromFinder)

        if !Preferences.loadFirstBoot()
        {
            lightVibrantWindow(helpWindowExtension)
            helpWindowExtension.center()
            helpWindowExtension.orderFrontRegardless()
            helpWindowExtension.makeKeyAndOrderFront(nil)
        
            _ = Preferences.activeSound(true)
            _ = Preferences.useRevealInFinder(false)
            _ = Preferences.openFileOnCreation(false)
            _ = Preferences.setFirstBoot(true)
            
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
        
        self.controller = NSPopover()//WOMController()
//        self.controller.menulet.imagesDelegate = self

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.title = ""
        statusItem.isEnabled = true
        statusItem.highlightMode = true
        statusItem.target = self
        statusItem.action = #selector(AppDelegate.togglePopover(_:))
        
        let image : NSImage! = NSImage(named: "icon-menulet")
        image.isTemplate = true
        
        statusItem.image = image
        statusItem.highlightMode = false
        statusItem.image = image

        REGISTER_NOTIFICATION(self, selector: #selector(AppDelegate.eventLoadPopUp(_:)), name: kPopOverDidLoad)
        REGISTER_NOTIFICATION(self, selector: #selector(AppDelegate.eventFinderSync(_:)), name: kFinderSyncOption)
        REGISTER_NOTIFICATION(self, selector: #selector(AppDelegate.eventTodayExtension(_:)), name: kTodayExtensionOption)
        REGISTER_NOTIFICATION(self, selector: #selector(AppDelegate.eventTodayExtension(_:)), name: kTodayExtensionOption)
        
        self.dataFiles = NSMutableArray(array:extractFiles())
        
        let 👿 : Bool = self.launchOnLogin()
        
        SMLog("is lanch a start: " + (👿 ? "YES" : "NO"))
        
        REGISTER_DISTRIBUTED_NOTIFICATION(self,
                                          selector: #selector(AppDelegate.eventNotifyDarkModeChanged(_:)),
                                          name: kChangeInterfaceNotification)
        
        REGISTER_DISTRIBUTED_NOTIFICATION(self,
                                          selector: #selector(AppDelegate.eventNotifySuspend(_:)),
                                          name: NSWindow.didResignKeyNotification.rawValue)

        let customViewPopOver : NSView = createCustomView()
        
        let viewController : NSViewController = NSViewController()
        viewController.view = customViewPopOver
        
        self.controller.delegate = self
        self.controller.contentViewController = viewController
        self.controller.behavior = .transient
        
        SCHEDULE_POSTNOTIFICATION(kChangeInterfaceNotification, object: nil)
        
        self.fastWindow = createFastWindow()
    
        super.awakeFromNib()
    }
    
    func createFastWindow() -> NSWindow {
        
        let winFast: NSWindow = NSWindow()
        winFast.title = "Fast New File Creation..."
        
        var frame = winFast.frame
        frame.size = NSSize(width: 364, height:450)
        winFast.setFrame(frame, display: true)
        
        winFast.isReleasedWhenClosed = false
        winFast.hidesOnDeactivate = false
//        winFast.isFloatingPanel = true // NSPanel only
        winFast.styleMask = NSWindow.StyleMask([.titled, .closable, .hudWindow, .nonactivatingPanel, .borderless])
        winFast.collectionBehavior = NSWindow.CollectionBehavior([.canJoinAllSpaces, .fullScreenAuxiliary])

        winFast.titlebarAppearsTransparent = false
        winFast.standardWindowButton(.miniaturizeButton)?.isHidden = true
        winFast.standardWindowButton(.zoomButton)?.isHidden = true
        
        let overlayScrollViewMiniHUD : SMScrollView = SMScrollView(frame: NSMakeRect(-10, 0, frame.width + 50, frame.height - 30))

        overlayScrollViewMiniHUD.verticalLineScroll = 1.0
        overlayScrollViewMiniHUD.verticalPageScroll = 1.0
        overlayScrollViewMiniHUD.hasVerticalScroller = true
        overlayScrollViewMiniHUD.backgroundColor = NSColor.clear
        overlayScrollViewMiniHUD.scrollerStyle = NSScroller.Style.overlay
        overlayScrollViewMiniHUD.hasHorizontalScroller = false
        overlayScrollViewMiniHUD.drawsBackground = false
        overlayScrollViewMiniHUD.pageScroll = overlayScrollViewMiniHUD.contentSize.height
        overlayScrollViewMiniHUD.scrollerKnobStyle = NSScroller.KnobStyle.dark
        overlayScrollViewMiniHUD.wantsLayer = true
        
        self.tableHUD = NSTableView(frame: NSMakeRect(0, 0, frame.width, frame.height))
        
        // Set style to plain to prevent any inset
        if #available(OSX 11.0, *) {
            self.tableHUD.style = .plain
        }

        tableHUD.enclosingScrollView?.borderType = .noBorder
        
        tableHUD.target = self
//        tableHUD.doubleAction = #selector(AppDelegate.doubleClick(_:))

        tableHUD.selectionHighlightStyle = NSTableView.SelectionHighlightStyle.none
        tableHUD.layer?.cornerRadius = 0
        tableHUD.layer?.borderColor = NSColor.clear.cgColor
        tableHUD.headerView = nil
        tableHUD.layer?.backgroundColor = NSColor.clear.cgColor
        tableHUD.delegate = self
        tableHUD.dataSource = self
        tableHUD.backgroundColor = NSColor.clear
        
        //Registering dragged Types
      
        let NSFilenamesPboardTypeTemp = NSPasteboard.PasteboardType("NSFilenamesPboardType")

        // NSFilenamesPboardType
        tableHUD.registerForDraggedTypes([NSFilenamesPboardTypeTemp])
        
        //To support across application passing NO
        tableHUD.setDraggingSourceOperationMask(NSDragOperation.copy, forLocal: false)
     
        let column1 : NSTableColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "columnHUD1"))
     
        column1.width = frame.width
        
        column1.resizingMask = NSTableColumn.ResizingOptions.autoresizingMask
        
        tableHUD.addTableColumn(column1)

        tableHUD.columnAutoresizingStyle = NSTableView.ColumnAutoresizingStyle.uniformColumnAutoresizingStyle
        column1.resizingMask = NSTableColumn.ResizingOptions.autoresizingMask
        tableHUD.sizeLastColumnToFit()

        overlayScrollViewMiniHUD.documentView = self.tableHUD

//        winFast.contentView = overlayScrollViewMiniHUD
        winFast.contentView?.addSubview(overlayScrollViewMiniHUD)
    
        winFast.center()
        
        Utils.positionWindowAtCenter(sender: winFast)

        tableHUD.setNeedsDisplay()
        tableHUD.reloadData()
        
        return winFast
    }
    
    @objc func togglePopover(_ sender: AnyObject) {
        
        if controller.isShown
        {
            closePopover(sender)
        }
        else
        {
            showPopover(sender)
        }
    }
    
    func closePopover(_ sender: AnyObject) {

        controller.performClose(sender)
    }
    
    func showPopover(_ sender: AnyObject) {

        controller.show(relativeTo: NSMakeRect(0, 0, 50, 50), of: sender as! NSView, preferredEdge: NSRectEdge.minY)
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
    
    @objc func doubleClick(_ object : AnyObject) {
    
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
        let split : [String] = templateFile.components(separatedBy: ".")
        let extensionString : String = split[1]
        
        self.savePanel.nameFieldStringValue = kFileName + "." + extensionString
        self.savePanel.becomeFirstResponder()
        self.savePanel.title = SMLocalizedString("saveNewFileAs")
        self.savePanel.showsTagField = false
        self.savePanel.showsHiddenFiles = false
        self.savePanel.showsToolbarButton = true
        self.savePanel.canCreateDirectories = true
        self.savePanel.becomeMain()
        self.savePanel.level = NSWindow.Level(rawValue: 0)//Int(CGWindowLevelKey(key: CGWindowLevelKey.ModalPanelWindowLevelKey)?.rawValue)
        self.savePanel.showsResizeIndicator = false
        self.savePanel.disableSnapshotRestoration()
        self.savePanel.isExtensionHidden = false
        self.savePanel.allowedFileTypes = nil
        self.savePanel.center()
        
        NSApp.mainWindow?.makeKeyAndOrderFront(self.savePanel)
        
        let destination : URL = target
        
        self.savePanel.directoryURL = destination
        self.savePanel.isAutodisplay = true
        let result : NSApplication.ModalResponse = self.savePanel.runModal()
        var error : NSError?
        
        if (error != nil)
        {
            SMLog(error!.localizedDescription)
            NSApp.presentError(error!)
            
            self.isShowing = false
            
            return
        }
//        NSApplication.ModalResponse.continue
        
//        self.savePanel.begin { (result : NSApplication.ModalResponse) in
        
//        }
//        self.savePanel.begin { ( result :Int) in
            
//            if (result == NSFileHandlingPanelCancelButton)
            if (result == NSApplication.ModalResponse.cancel)
            {
                self.isShowing = false
            }
            
//            if (result == NSFileHandlingPanelOKButton)
            if (result == NSApplication.ModalResponse.OK)
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
                    SMLog("error: " + error!.localizedDescription)
                }
                
                self.isShowing = false
            }
//        }
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
        window.appearance = NSAppearance(named: NSAppearance.Name.vibrantLight)
        
        let visualEffectView = NSVisualEffectView(frame: NSMakeRect(0, 0, window.frame.width, window.frame.height))
        visualEffectView.material = NSVisualEffectView.Material.light
        visualEffectView.blendingMode = NSVisualEffectView.BlendingMode.behindWindow
        visualEffectView.state = NSVisualEffectView.State.active
        
//        window.styleMask = NSWindow.StyleMask.fullSizeContentView
        window.titlebarAppearsTransparent = true

        window.contentView!.addSubview(visualEffectView, positioned: NSWindow.OrderingMode.below, relativeTo: nil)
        window.contentView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[visualEffectView]-0-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["visualEffectView":visualEffectView]))
        window.contentView!.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[visualEffectView]-0-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: ["visualEffectView":visualEffectView]))
    }
    
    func launchOnLogin() -> Bool
    {
        return AgentController.checkLogin(forIdentifier: kLoginHelperDekstopBundleIdentifier)
    }
    
    @objc func checkBoxAction(_ 😎 : AnyObject)
    {
        let checkButton : NSButton = 😎 as! NSButton
        
        if (checkButton.state == .on)
        {
            SMLog("on")
        }
        else
        {
            SMLog("off")
        }
        
        if (checkButton.state == .on)
        {
            _ = Preferences.wantsLaunchAtLogin(true)
        }
        else
        {
            _ = Preferences.wantsLaunchAtLogin(false)
        }
    
        if (checkButton.state == .on)
        {
            // ON
            // Turn on launch at login
            if (!AgentController.enableLoginItem(forIdentifier: kLoginHelperDekstopBundleIdentifier, forStatus: true))
            {
                SMLog("Couldn't add Helper App to launch at login item list.")
            }
        }
        
        if (checkButton.state == .off)
        {
            // OFF
            // Turn off launch at login
            if (!AgentController.enableLoginItem(forIdentifier: kLoginHelperDekstopBundleIdentifier, forStatus: false))
            {
                SMLog("Couldn't remove Helper App from launch at login item list.")
            }
        }
    }
    
    @objc func closeApplication(_ sender: AnyObject)
    {
        NSApplication.shared.terminate(self)
    }
    
    func createPreferencesWindowController()
    {
        if (preferencesWindowController == nil)
        {
            let generalViewController : NSViewController = GeneralPreferencesViewController(nibName: "GeneralPreferencesView", bundle: nil)

//            generalViewController.resignFirstResponder()
            
            advancedViewController = FilesPreferencesViewController(nibName: "FilesPreferencesViewController", bundle: nil)
//            advancedViewController.resignFirstResponder()
            
            REGISTER_NOTIFICATION(advancedViewController, selector: Selector(("eventUpdateSettingsCloud:")), name: kUpdateSettingCloud)
            
            3REGISTER_NOTIFICATION(advancedViewController, selector: Selector(("eventUpdateTableRows:")), name: kEventUpdateRowsNow)
            
            let cloudViewController : NSViewController = CloudSyncViewController(nibName: "CloudSyncViewController", bundle: nil)
            
//            cloudViewController.resignFirstResponder()
            
            let helpViewController : NSViewController = HelpPreferencesViewController(nibName: "HelpPreferencesViewController", bundle: nil)
            
//            helpViewController.resignFirstResponder()
            
            var controllers : NSArray? = NSArray(objects: generalViewController, advancedViewController as Any, cloudViewController, helpViewController)
            
            if #available(OSX 10.12.2, *) {
                
                let touchBarViewController : NSViewController = TouchBarPreferencesViewController(nibName: "TouchBarPreferencesViewController", bundle: nil)
                
//                touchBarViewController.resignFirstResponder()
                
                controllers = NSArray(objects: generalViewController, advancedViewController as Any, cloudViewController, touchBarViewController, helpViewController)
            }
         
            preferencesWindowController = MASPreferencesWindowController(viewControllers: controllers! as [AnyObject] , title:SMLocalizedString("settings"))
            
//            preferencesWindowController.resignFirstResponder()
            
            let button = preferencesWindowController.window!.standardWindowButton(NSWindow.ButtonType.zoomButton)
            button?.isEnabled = false
            
            preferencesWindowController.window!.standardWindowButton(.miniaturizeButton)?.isHidden = true
            preferencesWindowController.window!.standardWindowButton(.zoomButton)?.isHidden = true
        }
    }
    
    func showWindowPreferences()
    {
        if (controller != nil)
        {
//            controller.closePopover()
            controller.close()
        }
        
        createPreferencesWindowController()
        
        preferencesWindowController.showWindow(nil)
    }
    
    @objc func showPreferences(_ sender: AnyObject)
    {
        closePopUpController()
        
        NSApp.activate(ignoringOtherApps: false)
        NSApp.activate(ignoringOtherApps: true)
        showWindowPreferences()
        preferencesWindowController.selectedViewController = preferencesWindowController.viewController(forIdentifier: SMLocalizedString("general"))
        
        AppDelegate.preferencesWindow().makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func closePopUpController()
    {
        if (controller != nil)
        {
//            controller.closePopover()
            controller.close()
        }
    }
    
    func createCustomView() -> NSView
    {
        let customView : NSView = NSView(frame: NSMakeRect(0, 0, 364, 425))
        customView.appearance = NSAppearance(named: NSAppearance.Name.aqua)

        let buttonClose : NSButton = NSButton(frame: NSMakeRect(27, 350, 150, 40))
        
        buttonClose.title = SMLocalizedString("exitApp")
        buttonClose.setButtonType(NSButton.ButtonType.momentaryPushIn)
        buttonClose.bezelStyle = NSButton.BezelStyle.rounded
        buttonClose.target = self
        buttonClose.action = #selector(AppDelegate.closeApplication(_:))
        buttonClose.focusRingType = .none
        
        customView.addSubview(buttonClose)
        
        let buttonPreferences : NSButton = NSButton(frame: NSMakeRect(188, 350, 150, 40))
        
        buttonPreferences.title = SMLocalizedString("settings")
        buttonPreferences.setButtonType(NSButton.ButtonType.momentaryPushIn)
        buttonPreferences.bezelStyle = NSButton.BezelStyle.rounded
        buttonPreferences.target = self
        buttonPreferences.action = #selector(AppDelegate.showPreferences(_:))
        buttonPreferences.focusRingType = .none
        
        customView.addSubview(buttonPreferences)
        
        checkBox = NSButton(frame: NSMakeRect(10, 390, 240, 40))
        
        checkBox.target = self
        checkBox.action = #selector(AppDelegate.checkBoxAction(_:))
        checkBox.setButtonType(NSButton.ButtonType.switch)
        checkBox.state = (Preferences.isLaunchedAtLogin() ? .on : .off)
        checkBox.setNeedsDisplay()
        checkBox.attributedTitle = createAttributeStringForButton(SMLocalizedString("launchLogin"))
        checkBox.focusRingType = .none
        customView.addSubview(checkBox)
        
        let helpButton : NSButton = NSButton()
        
        helpButton.title = ""
        helpButton.frame = CGRect(x: 325, y: 388, width: 40, height: 40)
        helpButton.bezelStyle = NSButton.BezelStyle.helpButton
        helpButton.target = self
        helpButton.action = #selector(AppDelegate.showHelpAttached(_:))
        helpButton.focusRingType = .none
        helpButton.alignment = .natural
        helpButton.baseWritingDirection = .natural

        customView.addSubview(helpButton)
        
        let overlayScrollView : SMScrollView = SMScrollView(frame: NSMakeRect(-2, 0, customView.frame.width + 4, 350))

        overlayScrollView.verticalLineScroll = 1.0
        overlayScrollView.verticalPageScroll = 1.0
        overlayScrollView.hasVerticalScroller = true
        overlayScrollView.backgroundColor = NSColor.clear
        overlayScrollView.scrollerStyle = NSScroller.Style.overlay
        overlayScrollView.hasHorizontalScroller = false
        overlayScrollView.drawsBackground = false
        overlayScrollView.pageScroll = overlayScrollView.contentSize.height
        overlayScrollView.scrollerKnobStyle = NSScroller.KnobStyle.dark
        overlayScrollView.wantsLayer = true
        
        self.table = NSTableView(frame: NSMakeRect(0, 0, overlayScrollView.frame.size.width, overlayScrollView.frame.height))
        
        // Set style to plain to prevent any inset
        if #available(OSX 11.0, *) {
            self.table.style = .plain
        }

        table.enclosingScrollView?.borderType = .noBorder
        
        table.target = self
        table.doubleAction = #selector(AppDelegate.doubleClick(_:))

        table.selectionHighlightStyle = NSTableView.SelectionHighlightStyle.none
        table.layer?.cornerRadius = 0
        table.layer?.borderColor = NSColor.clear.cgColor
        table.headerView = nil
        table.layer?.backgroundColor = NSColor.clear.cgColor
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = NSColor.clear
        
        //Registering dragged Types
      
        let NSFilenamesPboardTypeTemp = NSPasteboard.PasteboardType("NSFilenamesPboardType")

//        NSFilenamesPboardType
        table.registerForDraggedTypes([NSFilenamesPboardTypeTemp])
        
        //To support across application passing NO
        table.setDraggingSourceOperationMask(NSDragOperation.copy, forLocal: false)
       
        let column1 : NSTableColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "column1"))
        
        if #available(OSX 11.0, *) {
            column1.width = customView.frame.size.width
        } else {
            column1.width = customView.frame.size.width - 2
        }
        
        column1.resizingMask = NSTableColumn.ResizingOptions.autoresizingMask
        
        table.addTableColumn(column1)
   
        overlayScrollView.documentView = self.table
        customView.addSubview(overlayScrollView)
       
        table.columnAutoresizingStyle = NSTableView.ColumnAutoresizingStyle.uniformColumnAutoresizingStyle
        column1.resizingMask = NSTableColumn.ResizingOptions.autoresizingMask
        table.sizeLastColumnToFit()

        if #available(OSX 11.0, *) {
            table.enclosingScrollView?.contentView.automaticallyAdjustsContentInsets = false
            table.enclosingScrollView?.contentView.contentInsets = .init(top: 0, left: -10, bottom: 0, right: -10)
        }
 
        table.reloadData()
        
        return customView
    }
    
    @objc func showHelpAttached(_ sender: AnyObject)
    {
        NSApp.activate(ignoringOtherApps: false)
        NSApp.activate(ignoringOtherApps: true)
        
        showWindowPreferences()
        preferencesWindowController.selectedViewController = preferencesWindowController.viewController(forIdentifier: SMLocalizedString("help"))

        AppDelegate.preferencesWindow().makeKeyAndOrderFront(nil)
        
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func createHelpView() -> NSTextView
    {
        let textView : NSTextView = NSTextView(frame: CGRect.zero)
        
        textView.maxSize = NSMakeSize(CGFloat.greatestFiniteMagnitude, CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = true
        textView.autoresizingMask = NSView.AutoresizingMask.width
        textView.textContainer?.widthTracksTextView = true
        textView.string = SMLocalizedString("dragAndDropItems")
        textView.backgroundColor = NSColor.clear
        textView.textColor = NSColor.white
        
        let size : NSRect  = SMObject.calculateSizeForText(textView.string as NSString, textView: textView)
        
        textView.frame = size
        
        return textView
    }
    
    func createAttributeStringForButton(_ title : String) -> NSAttributedString
    {
        let color : NSColor = (darkModeOn!) ? NSColor.white : NSColor.black

        let attrTitle = NSMutableAttributedString(string: title)
        
        attrTitle.addAttribute(NSAttributedString.Key.font, value: NSFont(name: "Helvetica", size: 13.0)!, range: NSMakeRange(0, attrTitle.length))
        attrTitle.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSMakeRange(0, attrTitle.length))

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
        if (tableColumn!.identifier.rawValue == "column1" || tableColumn!.identifier.rawValue == "columnHUD1")
        {
            let cellView = NSView(frame: NSMakeRect(0, 0, tableView.frame.size.width, CELL_HEIGHT))
            cellView.identifier = NSUserInterfaceItemIdentifier(rawValue: "row" + String(row))
            
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

            let components : [String]? = value.components(separatedBy: ".") as [String]?
            
            var image : NSImage = NSWorkspace.shared.icon(forFileType:"sh")
            
            if (components != nil)
            {
                image = (components!.count > 1) ? NSWorkspace.shared.icon(forFileType: components![1]) : NSWorkspace.shared.icon(forFileType:"svg")
            }
            
            let imageView : NSImageView = NSImageView(frame: NSMakeRect(10, 0, 50, 50))
            imageView.image = image
            
            cellView.addSubview(imageView)
            
            let textField : NSTextField = NSTextField(frame: NSMakeRect(80, 12, 270, 20))
        
            textField.textColor = NSColor.black
            
            var extensionFile : String = "sh"
            
            if (components != nil)
            {
                extensionFile  = (components!.count > 1) ? components![1].uppercased() : extensionFile
            }
            
            textField.stringValue = NSString(format: SMLocalizedString("newFileMask") as NSString, extensionFile, value) as String
            textField.alignment = NSTextAlignment.left
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
        pboard.declareTypes([NSPasteboard.PasteboardType.filePromise], owner:self)
        
        // the pasteboard must know the type of files being promised
        let filenameExtensions : NSMutableArray = NSMutableArray()
        
        // iterate the selected files in your NSArrayController and get the extension from each file,
        // we're assuming that you store the file's filename in Core Data as an attribute
        let selectedObjects : NSArray = self.dataFiles.objects(at: rowIndexes) as NSArray
 
        for file in selectedObjects as! [String]
        {
            let components : [String] = file.components(separatedBy: ".")
            
            var extensionFile : String = "sh"
            
            if (components.count > 1)
            {
                extensionFile = components[1] as String
            }

            if (extensionFile != "")
            {
                filenameExtensions.add(extensionFile)
            }
        }
        
        // give the pasteboard the file extensions
        pboard.setPropertyList(filenameExtensions, forType: NSPasteboard.PasteboardType.filePromise)
        
        return true
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation
    {
        if dropOperation == .above
        {
            return .move
        }
        
        return NSDragOperation()
    }
    
    func isDirectory(pathURL: NSURL) -> Bool {
        
        var isDirectory : ObjCBool = false
        let fileExistsAtPath : Bool  = Foundation.FileManager.default.fileExists(atPath: pathURL.path!, isDirectory: &isDirectory)
        
        if (fileExistsAtPath)
        {
            if (pathURL.pathExtension?.lowercased() == "rtfd")
            {
                // rtfd is a file
                return false
            }
            
            if isDirectory.boolValue
            {
                // It's a Directory.
                return true
            }
        }
        
        return false
    }
    
    func addURLFile(fileURLItem: URL) {
        
        let choosenFile : URL! = (fileURLItem as NSURL).filePathURL!
        
        let pathString : String = choosenFile.resolvingSymlinksInPath().path
        
        //                    let fileManager : NSFileManager = NSFileManager()
        let finalPath : String = FileManager.applicationDirectory().appendingPathComponent(choosenFile.lastPathComponent)
        
        var exists : Bool = false
        
        for item in FileManager.listTemplates()
        {
            let itemStr : String = item as! String
            
            if (NSURL(fileURLWithPath: itemStr).lastPathComponent!.lowercased() == NSURL(fileURLWithPath: finalPath).lastPathComponent!.lowercased())
            {
                exists = true
                break
            }
        }
        
        if exists
        {
            SMLog("plantilla ya existe")
            
            SMObject.showModalAlert(SMLocalizedString("warning"), message: SMLocalizedString("templateExists"))
        }
        else
        {
            _ = FileManager.copyNewTemplateFileToApplicationSupport(pathString)
            
            SMLog("path: " + pathString)
            
            let dict : NSMutableDictionary = NSMutableDictionary()
            
            dict.setObject(1, forKey: "enableColumn" as NSCopying)
            dict.setObject(1, forKey: "active" as NSCopying)
            
            let tempURL : URL = URL(fileURLWithPath: pathString)
            dict.setObject(tempURL.lastPathComponent, forKey: "templateColumn" as NSCopying)
            
            let templatesArray : NSMutableArray = NSMutableArray(array: Preferences.loadTemplatesTablePreferences())
            
            templatesArray.add(dict)
            
            _ = Preferences.setTemplatesTablePreferences(templatesArray)
            
            self.dataFiles = NSMutableArray(array: self.obtainRows())
            
            self.table.reloadData()
            
            if (self.dataFiles.count > 0)
            {
                self.table.scrollRowToVisible(self.dataFiles.count - 1)
            }
            
            SCHEDULE_POSTNOTIFICATION(kUpdateTableFromPreferences, object: nil)
        }
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool
    {
        var oldIndexes = [Int]()
        
        info.enumerateDraggingItems(options: [], for: tableView, classes: [NSPasteboardItem.self], searchOptions: [:]) { ( draggingItem: NSDraggingItem, idx: Int, stop: UnsafeMutablePointer<ObjCBool>) in
            
            let pasteItem : NSPasteboardItem = (draggingItem.item as! NSPasteboardItem)
            let strIndex: String? = pasteItem.string(forType: NSPasteboard.PasteboardType(rawValue: "public.data"))
            
            if (strIndex != nil)
            {
                if let index = Int(strIndex!)
                {
                    oldIndexes.append(index)
                }
            }
            //            else
            //            {
            //                let path = pasteItem.string(forType: NSPasteboard.PasteboardType(rawValue: "public.file-url"))
            //            let url : NSURL = NSURL(fileURLWithPath: path!)
            //            print("\(url.absoluteString!)")
            
            //                let pb: NSPasteboard = info.draggingPasteboard()
            
            //list the file type UTIs we want to accept
            //                NSArray* acceptedTypes = [NSArray arrayWithObject:"public.file-url"];
            
            //                let filteringOptions = [NSPasteboard.ReadingOptionKey.urlReadingContentsConformToTypes:"public.file-url"]
            //
            //                let arrayURLs: NSArray = pb.readObjects(forClasses: [NSURL.self], options: filteringOptions)! as NSArray
            //                print("cocunt urls: \(arrayURLs.count)")
            //                NSArray* urls = [pb readObjectsForClasses:[NSArray arrayWithObject:[NSURL class]]
            //                    options:[NSDictionary dictionaryWithObjectsAndKeys:
            //                    [NSNumber numberWithBool:YES],NSPasteboardURLReadingFileURLsOnlyKey,
            //                    acceptedTypes, NSPasteboardURLReadingContentsConformToTypesKey,
            //                    nil]];
            //            }
        }
        //        info.enumerateDraggingItems(options: [], for: tableView, classes: [NSPasteboardItem.self], searchOptions: [:]) {
        //
        //            if let index = Int((($0.0.item as! NSPasteboardItem).string(forType: "public.data"))!)
        //            {
        //                oldIndexes.append(index)
        //            }
        //        }
        
        if (oldIndexes.count == 0)
        {
            let pb: NSPasteboard = info.draggingPasteboard
            
            let filteringOptions : [NSPasteboard.ReadingOptionKey : Any] = [NSPasteboard.ReadingOptionKey.urlReadingFileURLsOnly : NSNumber.init(booleanLiteral: true)]
            
            let arrayURLs: NSArray = pb.readObjects(forClasses: [NSURL.self as AnyClass], options: filteringOptions)! as NSArray
            SMLog("count urls: \(arrayURLs.count)")
            
            for itemURL in arrayURLs {
                
                let url: NSURL = itemURL as! NSURL
                
                if (!self.isDirectory(pathURL: url)) {
                    
                    self.addURLFile(fileURLItem: URL(fileURLWithPath: url.path!))
                }
                
                SMLog("url path: \(String(describing: url.path))")
            }
        }
        else
        {
            var oldIndexOffset = 0
            var newIndexOffset = 0
            
            // For simplicity, the code below uses `tableView.moveRowAtIndex` to move rows around directly.
            // You may want to move rows in your content array and then call `tableView.reloadData()` instead.
            tableView.beginUpdates()
            
            for oldIndex in oldIndexes
            {
                if oldIndex < row
                {
                    let finalOldIndex : Int = oldIndex + oldIndexOffset
                    let finalNewIndex : Int = row - 1
                    
                    tableView.moveRow(at: finalOldIndex, to: finalNewIndex)
                    oldIndexOffset -= 1
                    
                    SMLog("old index: \(finalOldIndex) new index: \(finalNewIndex)")
                    
                    let object : NSMutableDictionary = dataFiles[finalOldIndex] as! NSMutableDictionary
                    
                    let tempArray : NSMutableArray = NSMutableArray(array: Preferences.loadTemplatesTablePreferences())
                    
                    let originalNewIndex : Int = tempArray.index(of: dataFiles[finalNewIndex] as! NSMutableDictionary)
                    let originalOldIndex : Int = tempArray.index(of: dataFiles[finalOldIndex] as! NSMutableDictionary)
                    
                    tempArray.removeObject(at: originalOldIndex)
                    tempArray.insert(object, at: originalNewIndex)
                    
                    _ = Preferences.setTemplatesTablePreferences(tempArray)
                    
                    dataFiles.removeObject(at: finalOldIndex)
                    dataFiles.insert(object, at: finalNewIndex)
                }
                else
                {
                    let finalOldIndex : Int = oldIndex
                    let finalNewIndex : Int = row + newIndexOffset
                    
                    tableView.moveRow(at: finalOldIndex, to: finalNewIndex)
                    newIndexOffset += 1
                    SMLog("old index: \(finalOldIndex) new index: \(finalNewIndex)")
                    
                    let object : NSMutableDictionary = dataFiles[finalOldIndex] as! NSMutableDictionary
                    
                    let tempArray : NSMutableArray = NSMutableArray(array: Preferences.loadTemplatesTablePreferences())
                    
                    let originalNewIndex : Int = tempArray.index(of: dataFiles[finalNewIndex] as! NSMutableDictionary)
                    let originalOldIndex : Int = tempArray.index(of: dataFiles[finalOldIndex] as! NSMutableDictionary)
                    
                    tempArray.removeObject(at: originalOldIndex)
                    tempArray.insert(object, at: originalNewIndex)
                    
                    _ = Preferences.setTemplatesTablePreferences(tempArray)
                    
                    dataFiles.removeObject(at: finalOldIndex)
                    dataFiles.insert(object, at: finalNewIndex)
                }
            }
            
            tableView.endUpdates()
        }
        
        tableView.reloadData()
        
        SCHEDULE_POSTNOTIFICATION(kUpdateTableFromPreferences, object: nil)
        
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
        
//        REGISTER_DISTRIBUTED_NOTIFICATION(self, selector: #selector(AppDelegate.eventFinderExtensionNotification(_:)), name: kFinderExtensionUpdate)
   
        return draggedFilenames as NSArray as! [String]
    }
    
    func observerDarkMode() -> Bool
    {
//        let dict : NSDictionary = NSUserDefaults.standardUserDefaults().persistentDomainForName(NSGlobalDomain)!
//        var style : AnyObject? = dict.objectForKey("AppleInterfaceStyle")
        
        darkModeOn = isDarkModeEnabled()
        
//        var color : NSColor = NSColor.white
//        let colorTitle : NSMutableAttributedString = NSMutableAttributedString(attributedString: checkBox.attributedTitle)
//        let titleRange : NSRange = NSMakeRange(0, colorTitle.length)
        
        if darkModeOn == false
        {
            SMLog("dark mode")

            checkBox?.attributedTitle = createAttributeStringForButton(SMLocalizedString("launchLogin"))
            
//            colorTitle.addAttributes([NSAttributedStringKey.foregroundColor : color], range: titleRange)
//            checkBox.attributedTitle = colorTitle
        }
        else
        {
            checkBox?.attributedTitle = createAttributeStringForButton(SMLocalizedString("launchLogin"))
//            color = NSColor.black
//
//            colorTitle.addAttributes([NSAttributedStringKey.foregroundColor : color], range: titleRange)
//            checkBox.attributedTitle = colorTitle
            
            SMLog("light mode")
        }

        return darkModeOn
    }
    
    //MARK: - NSNotification methods

    @objc func eventFinderExtensionNotification(_ notification : Notification) {
        
        SMLog("arrived in finderExtensionNotification")

        DispatchQueue.main.async(execute: { [self] in
            
            self.isShowing = true
            
            if (self.fastWindow == nil) {
                self.fastWindow = self.createFastWindow()
            }
            
            self.fastWindow.makeKeyAndOrderFront(nil)
            self.fastWindow.level = .modalPanel
            self.fastWindow.orderFront(nil)
        })
    }
    
    @objc func eventAddFileFromExtensionFinder(_ notification : Notification) {
        
        let urls : [String] = Preferences.getSelectedFilesExtension()
       
        if urls.count > 0 {

            for urlString in urls {
                
                let url : URL = URL(fileURLWithPath: urlString)
                self.addURLFile(fileURLItem: url)
            }
        }
        
        SMLog("arrived in eventAddFileFromExtensionFinder")
    }
                          
    @objc func eventUpdateTableFromPreferences(_ notification : Notification)
    {
        DispatchQueue.main.async(execute: { [self] in
            
            SMLog("llega eventUpdateTableFromPreferences")
            SMLog("pasa eventUpdateTableFromPreferences1")
            let items : NSArray = NSArray(array: self.extractFiles())
            SMLog("pasa eventUpdateTableFromPreferences2")
            self.dataFiles = NSMutableArray(array:items)
            SMLog("pasa eventUpdateTableFromPreferences3")
            self.table.reloadData()
            SMLog("pasa eventUpdateTableFromPreferences4")
            
            // Update Today Extension
            SCHEDULE_POSTNOTIFICATION(kTodayExtensionOption, object: nil)
            SCHEDULE_DISTRIBUTED_NOTIFICATION(name: kUpdateTodayExtension)
            
            SCHEDULE_DISTRIBUTED_NOTIFICATION(name: kUpdateSettingCloud)
            
            SCHEDULE_DISTRIBUTED_NOTIFICATION(name: kEventUpdateRowsNow)
            
            self.advancedViewController?.reloadTableFunction()
            
            if (tableHUD != nil) {
                tableHUD.reloadData()
            }
            
            if #available(OSX 10.12.2, *) {

                SMLog("refresca")
                self.reloadTouchBar()
            }
        })
    }
    
    @objc func eventFinderSync(_ notification : Notification)
    {
        SMLog("llega eventFinderSync")
    }
    
    @objc func eventTodayExtension(_ notification : Notification)
    {
        SMLog("llega eventTodayExtension")
    }

    @objc func eventLoadPopUp(_ notification : Notification)
    {
        //var controller : WOMPopoverController = notification.object as! WOMPopoverController
        
        let customViewPopOver : NSView = createCustomView()
        
//        self.controller.viewController.view.addSubview(customViewPopOver)
        let viewController : NSViewController = NSViewController()
        viewController.view = customViewPopOver
        
        self.controller.contentViewController = viewController
        self.controller.behavior = .transient
        
        SMLog("llega final")
    }
    
    @objc func eventNotifyDarkModeChanged(_ notification : Notification)
    {
//        SMLog("notification: %@", notification.object)

//        if (!self.controller.isActive)
//        if (!self.controller.isShown)
//        {
//            return
//        }
        
        if (observerDarkMode())
        {
            if controller != nil
            {
//                controller.viewController.popover.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
                controller.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
                tableHUD.appearance = NSAppearance(named: NSAppearance.Name.vibrantDark)
            }
        }
        else
        {
            if controller != nil
            {
//                controller.viewController.popover.appearance = NSAppearance(named: NSAppearance.Name.vibrantLight)
                controller.appearance = NSAppearance(named: NSAppearance.Name.vibrantLight)
                tableHUD.appearance = NSAppearance(named: NSAppearance.Name.vibrantLight)
            }
        }

        if (checkBox != nil)
        {
            checkBox.attributedTitle = createAttributeStringForButton("Launch at login")
        }
    }
    
    //WOMMenuletDelegateImages delegate methods
    
//    func activeImageName() -> String!
//    {
//        if (observerDarkMode())
//        {
//            return "icon-menulet-white"
//        }
//
//        return "icon-menulet"
//    }
//
//    func inactiveImageName() -> String!
//    {
//        if (observerDarkMode())
//        {
//            return "icon-menulet-white"
//        }
//
//        return "icon-menulet"
//    }
    
    //MARK: - NSPopoverDelegate delegate methods
    func popoverDidShow(_ notification: Notification) {
        
        let option = Preferences.popUpBehaviour()
        
        var behave : NSPopover.Behavior = .transient
        
//        if (option == SMPopUpState.transient.rawValue) {
//            
//            behave = .transient
//        }
        
        if (option == SMPopUpState.semiTransient.rawValue) {
            
            behave = .semitransient
        }
        
        if (option == SMPopUpState.applicationDefined.rawValue) {
            
            behave = .applicationDefined
        }
        
        controller.behavior = behave
    }
    
    @IBAction func openSystemPreferences(_ sender: AnyObject) {
        
        Utils.openExtensionPreferences()
    }
   
    //MARK: - Other application methods
    
    override func applicationDidFinishLaunching(_ aNotification: Notification)
    {
        super.applicationDidFinishLaunching(aNotification)

        if #available(OSX 10.12.2, *) {
            
            NSApplication.shared.isAutomaticCustomizeTouchBarMenuItemEnabled = true
            
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
    
    @objc func eventNotifySuspend(_ notification: Notification) {
        
        SMLog("llega")
    }
    
    //MARK: - NSTouchBarDelegate methods
    @available(OSX 10.12.2, *)
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        
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
        
        let files : NSArray = NSArray(array : extractFiles())
        
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
        scrollView.autoresizingMask = NSView.AutoresizingMask.width

        let separator : CGFloat = 16
        var offset : CGFloat = 0
        var position : Int = 0
        
        for item in files {
            
            let components : [String] = (item as AnyObject).components(separatedBy: ".") as [String]
            
            var extensionItem : String = "sh"
            
            if (components.count > 1)
            {
                extensionItem = components[1] as String
            }

            var image : NSImage = NSWorkspace.shared.icon(forFileType: extensionItem)
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

        let customItem : NSCustomTouchBarItem = NSCustomTouchBarItem.init(identifier: .customViewIdentifier)
        
        customItem.view = scrollView
        
        return customItem
    }

    @available(OSX 10.12.2, *)
    func makeButtonWithIdentifier(title: String, image: NSImage) -> NSButton {
        
        var tempTitle = title
        
        if (Preferences.showTitleTouchBarButtons() == false)
        {
            tempTitle = ""
        }
        
        let button : NSButton = NSButton(title: tempTitle, image: image, target: self, action: #selector(createNewFile(sender:)))
        
        return button
    }
    
    @objc func createNewFile(sender: NSButton) {
        
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
        let split : [String] = templateFile.components(separatedBy: ".")
        let extensionString : String = split[1]
        
        self.savePanel.nameFieldStringValue = kFileName + "." + extensionString
        self.savePanel.becomeFirstResponder()
        self.savePanel.title = (currentLanguage() == "es" || currentLanguage() == "es-es") ? "Guardar nuevo archivo como..." : "Save new file as..."
        self.savePanel.showsTagField = false
        self.savePanel.showsHiddenFiles = false
        self.savePanel.showsToolbarButton = true
        self.savePanel.canCreateDirectories = true
        self.savePanel.accessoryView = self.customViewTouchbar
        self.savePanel.becomeMain()
        self.savePanel.level = NSWindow.Level(rawValue: 0)//CGWindowLevelKey.ModalPanelWindowLevelKey
        self.savePanel.showsResizeIndicator = false
        self.savePanel.disableSnapshotRestoration()
        self.savePanel.isExtensionHidden = false
        self.savePanel.allowedFileTypes = nil
        self.savePanel.center()
        
        NSApp.mainWindow?.makeKeyAndOrderFront(self.savePanel)
        
        let destination : URL = target
        
        self.savePanel.directoryURL = destination
        self.savePanel.isAutodisplay = true
        
        self.savePanel.begin { ( result :NSApplication.ModalResponse) in
            
            var error : NSError?
            
            if result == NSApplication.ModalResponse.cancel {
                
                let rows : [String] = self.createRows() as! [String]
                
                self.popupButton.removeAllItems()
                self.popupButton.addItems(withTitles: rows)
                self.popupButton.selectItem(at: index)
                
                self.isShowing = false
            }
            
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
        
        labelField.stringValue = (currentLanguage() == "es" || currentLanguage() == "es-es") ? "Selecciona un tipo:" : "Select a file type:"
        
        labelField.textColor = (isDarkModeEnabled()) ? NSColor.white : NSColor.black
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
            let components : [String] = (file as AnyObject).components(separatedBy: ".")
            
            var extensionFile : String = "sh"
            
            if (components.count > 1)
            {
                extensionFile = components[1].uppercased() as String
            }

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
}
