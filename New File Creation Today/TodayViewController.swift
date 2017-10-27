//
//  TodayViewController.swift
//  New File Creation Today
//
//  Created by sid on 27/10/2017.
//  Copyright © 2017 com.sergiomtzlosa.filecreation. All rights reserved.
//

import Cocoa
import NotificationCenter

let CELL_HEIGHT : CGFloat = 50
let TABLE_HEIGHT : CGFloat = 400
let kFileName = "NewFile"

class TodayViewController: NSViewController, NCWidgetProviding, NSTableViewDataSource, NSTableViewDelegate {

    var appSettings : NSDictionary!
    var isShowing : Bool?
    var table : NSTableView!
    var savePanel : NSSavePanel!
    var dataFiles : NSArray = []
    var overlayScrollView : SMScrollView!
    
    var widgetAllowsEditing: Bool {
        return false
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
    }

    override func viewWillAppear() {

        presetMainView()
        updatePreferredContentSize()
        
        if (table == nil) {
            
            createTable()
        }

        super.viewWillAppear()
    }
    
    func updatePreferredContentSize() {
        
        if (table != nil) {
            
            table.needsLayout = true
            table.layoutSubtreeIfNeeded()
        }
        
        let height = TABLE_HEIGHT
        let width: CGFloat = 320
        
        preferredContentSize = CGSize(width: width, height: height)
    }
    
    override var nibName: NSNib.Name? {

        return NSNib.Name("TodayViewController")
    }
    
    override func present(inWidget viewController: NSViewController) {

    }

    override func viewWillTransition(to newSize: NSSize) {
       
    }

    func presetMainView() {
        
        self.dataFiles = NSArray(array:UtilsExtension.extractFilesExtension())
        self.appSettings = Preferences.readPlistApplicationPreferences()
        
        if table != nil {
            
            table.reloadData()
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {

        if (table != nil) 
        {
            completionHandler(.newData)
        }
        else
        {
            completionHandler(.noData)
        }
    }

    func createTable() {
        
        let customView : NSView = self.view
        overlayScrollView = SMScrollView(frame: NSMakeRect(0, 0, customView.frame.width, TABLE_HEIGHT))
        
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
        overlayScrollView.translatesAutoresizingMaskIntoConstraints = true
        
        table = NSTableView(frame: NSMakeRect(0, 0, overlayScrollView.frame.size.width, overlayScrollView.frame.height))
        
        table.translatesAutoresizingMaskIntoConstraints = true
        table.target = self;
        table.doubleAction = #selector(TodayViewController.doubleClick(_:));
        table.selectionHighlightStyle = NSTableView.SelectionHighlightStyle.none
        table.layer?.cornerRadius = 0
        table.layer?.borderColor = NSColor.clear.cgColor
        table.headerView = nil
        table.layer?.backgroundColor = NSColor.clear.cgColor
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = NSColor.clear
        table.columnAutoresizingStyle = .uniformColumnAutoresizingStyle
        
        //Registering dragged Types
        
        let NSFilenamesPboardTypeTemp = NSPasteboard.PasteboardType("NSFilenamesPboardType")
        
        //        NSFilenamesPboardType
        table.registerForDraggedTypes([NSFilenamesPboardTypeTemp])
        
        //To support across application passing NO
        table.setDraggingSourceOperationMask(NSDragOperation.copy, forLocal: false)
        
        let column1 : NSTableColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "column1"))
        
        column1.width = customView.frame.size.width
        column1.resizingMask = NSTableColumn.ResizingOptions.autoresizingMask
        
        table.addTableColumn(column1)
        
        overlayScrollView.documentView = table
        customView.addSubview(overlayScrollView)
        
        table.columnAutoresizingStyle = NSTableView.ColumnAutoresizingStyle.uniformColumnAutoresizingStyle
        column1.resizingMask = NSTableColumn.ResizingOptions.autoresizingMask
        table.sizeLastColumnToFit()
        
//        let topViews : [String : Any] = ["overlayScrollView" : overlayScrollView]
//
//        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[overlayScrollView]|", options: .alignAllLastBaseline, metrics: nil, views: topViews))
//
//        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[overlayScrollView]|", options: .alignAllLastBaseline, metrics:nil, views:topViews))
    }
    
    @objc func doubleClick(_ object : AnyObject) {
        
//        if (!Preferences.loadDoubleClick())
//        {
//            return
//        }
        
        let rowNumber : NSInteger = table.clickedRow
        
        if (dataFiles.count > 0)
        {
            let item : String = dataFiles[rowNumber] as! String
            
            let sourcePathFile : String = FileManager.resolvePathForFile(item)
 
            DispatchQueue.main.async(execute: {
            
                self.launchSavePanel(sourcePathFile)
            })
        }
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
        if tableColumn!.identifier.rawValue == "column1"
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
            
            var components : [String] = value.components(separatedBy: ".") as [String]
            
            let image : NSImage = NSWorkspace.shared.icon(forFileType: components[1])
            
            let imageView : NSImageView = NSImageView(frame: NSMakeRect(10, 0, 50, 50))
            imageView.image = image
            
            cellView.addSubview(imageView)
            
            let textField : NSTextField = NSTextField(frame: NSMakeRect(80, 12, 270, 20))
            
            textField.textColor = NSColor.black
            
            let extensionFile : String = components[1].uppercased()
            
//            SMLog("text cell: \(extensionFile)")
            let strText : String = NSString(format: SMLocalizedString("newFileMask") as NSString, extensionFile, value) as String

            if strText == "newFileMask"
            {
                textField.stringValue = ""
            }
            else
            {
                textField.stringValue = strText
            }

            textField.alignment = NSTextAlignment.left;
            textField.font = NSFont.systemFont(ofSize: 12)
            textField.isBezeled = false
            textField.drawsBackground = false
            textField.isEditable = false
            textField.isSelectable = false
            textField.backgroundColor = NSColor.clear
            textField.wantsLayer = true
            textField.layer?.backgroundColor = NSColor.clear.cgColor
            textField.lineBreakMode = NSParagraphStyle.LineBreakMode.byWordWrapping
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
            var components : [String] = file.components(separatedBy: ".")
            let extensionFile : String = components[1] as String
            
            if (extensionFile != "")
            {
                filenameExtensions.add(extensionFile)
            }
        }
        
        // give the pasteboard the file extensions
        pboard.setPropertyList(filenameExtensions, forType: NSPasteboard.PasteboardType.filePromise)
        
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
            
            if (Preferences.loadActiveSound())
            {
                NSSound(named: NSSound.Name(rawValue: "dropped"))?.play()
            }
        }
        
        return draggedFilenames as NSArray as! [String]
    }
    
    func launchSavePanel(_ sourceFile : String)
    {
        table.resignFirstResponder()
        
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
        self.savePanel.level = NSWindow.Level(rawValue: 0)//Int(CGWindowLevelKey(key: CGWindowLevelKey.ModalPanelWindowLevelKey)?.rawValue)
        self.savePanel.showsResizeIndicator = false
        self.savePanel.disableSnapshotRestoration()
        self.savePanel.isExtensionHidden = false
        self.savePanel.allowedFileTypes = nil
        self.savePanel.center()
        self.savePanel.becomeFirstResponder()
        
        NSApp.mainWindow?.makeKeyAndOrderFront(self.savePanel)
//        self.savePanel.runModal()
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
                    SMLog("error: " + error!.localizedDescription)
                }
                
                self.isShowing = false
            }
//        }
    }
    
    func widgetMarginInsets(forProposedMarginInsets defaultMarginInset: NSEdgeInsets) -> NSEdgeInsets {
        
        return NSEdgeInsetsZero
    }
    
//    @objc func eventTodayExtension(_ notification : Notification)
//    {
//        SMLog("llega extensiomn eventTodayExtension")
//
//        presetMainView()
//    }
}
