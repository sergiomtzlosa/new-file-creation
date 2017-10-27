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

class TodayViewController: NSViewController, NCWidgetProviding, NSTableViewDataSource, NSTableViewDelegate {

    var table : NSTableView!
    var dataFiles : NSArray = []
    
    override var nibName: NSNib.Name? {
        
        return NSNib.Name("TodayViewController")
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        
        // Update your data and prepare for a snapshot. Call completion handler when you are done
        // with NoData if nothing has changed or NewData if there is new data since the last
        // time we called you
        completionHandler(.noData)
    }

    func createTable() {
        
        let customView : NSView = self.view
        let overlayScrollView : SMScrollView = SMScrollView(frame: NSMakeRect(0, 0, customView.frame.width, 350))
        
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
        
        table = NSTableView(frame: NSMakeRect(-1, 0, overlayScrollView.frame.size.width + 1, overlayScrollView.frame.height))
        
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
        
        //Registering dragged Types
        
        let NSFilenamesPboardTypeTemp = NSPasteboard.PasteboardType("NSFilenamesPboardType")
        
        //        NSFilenamesPboardType
        table.registerForDraggedTypes([NSFilenamesPboardTypeTemp])
        
        //To support across application passing NO
        table.setDraggingSourceOperationMask(NSDragOperation.copy, forLocal: false)
        
        let column1 : NSTableColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "column1"))
        
        column1.width = customView.frame.size.width - 2
        column1.resizingMask = NSTableColumn.ResizingOptions.autoresizingMask
        
        table.addTableColumn(column1)
        
        overlayScrollView.documentView = table
        customView.addSubview(overlayScrollView)
        
        table.columnAutoresizingStyle = NSTableView.ColumnAutoresizingStyle.uniformColumnAutoresizingStyle
        column1.resizingMask = NSTableColumn.ResizingOptions.autoresizingMask
        table.sizeLastColumnToFit()
        
        table.reloadData()
    }
    
    @objc func doubleClick(_ object : AnyObject) {
        
//        if (!Preferences.loadDoubleClick())
//        {
//            return
//        }
//        
//        let rowNumber : NSInteger = table.clickedRow
//        
//        if (dataFiles.count > 0)
//        {
//            let item : String = dataFiles[rowNumber] as! String
//            
//            let sourcePathFile : String = FileManager.resolvePathForFile(item)
//            
//      
//            DispatchQueue.main.async(execute: {
//                
//                self.launchSavePanel(sourcePathFile)
//            })
//        }
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
            let
            cellView = NSView(frame: NSMakeRect(0, 0, tableView.frame.size.width, CELL_HEIGHT))
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
}
