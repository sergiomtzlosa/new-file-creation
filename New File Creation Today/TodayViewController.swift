//
//  TodayViewController.swift
//  New File Creation Today
//
//  Created by sid on 27/10/2017.
//  Copyright © 2017 com.sergiomtzlosa.filecreation. All rights reserved.
//

import Cocoa
import NotificationCenter

class TodayViewController: NSViewController, NCWidgetProviding, NSTableViewDataSource, NSTableViewDelegate {

    var table : NSTableView!
    
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
}
