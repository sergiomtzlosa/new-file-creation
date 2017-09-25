//
//  FilesPreferencesViewController.swift
//  New File Creation
//
//  Created by sid on 14/08/15.
//  Copyright (c) 2015 com.sergiomtzlosa.filecreation. All rights reserved.
//

import Foundation

class FilesPreferencesViewController : NSViewController, MASPreferencesViewController, NSTableViewDataSource, NSTableViewDelegate
{
    @IBOutlet var removeTemplateButton: NSButton!
    @IBOutlet var addTemplateButton: NSButton!
    @IBOutlet var table: NSTableView!
    @IBOutlet var tipCustomTemplates: NSTextField!
    @IBOutlet var resetDefaultsButton: NSButton!
    @IBOutlet var titleFilesLabel: NSTextField!
    
    var dataArray : NSMutableArray!
    
    override init(nibName nibNameString: NSNib.Name?, bundle bundleItem: Bundle?) {
        super.init(nibName: nibNameString, bundle: bundleItem)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("NSCoding not supported")
    }
    
    override func awakeFromNib() {

        var headerCell = table.tableColumns[0].headerCell 
        headerCell.stringValue = SMLocalizedString("enable")
        
        headerCell = table.tableColumns[1].headerCell 
        headerCell.stringValue = SMLocalizedString("icon")
        
        headerCell = table.tableColumns[2].headerCell 
        headerCell.stringValue = SMLocalizedString("template")
        
        titleFilesLabel.stringValue = SMLocalizedString("titleFilesLabel")
        resetDefaultsButton.title = SMLocalizedString("resetDefaultsTemplate")
        tipCustomTemplates.stringValue = SMLocalizedString("tipCustomTemplates")
        
        dataArray = NSMutableArray(array: obtainRows())
        
        table.dataSource = self
        table.delegate = self
        table.selectionHighlightStyle = NSTableView.SelectionHighlightStyle.regular
        
        table.reloadData()
     
        //NSPasteboard.PasteboardType("public.file-url")
        table.registerForDraggedTypes([NSPasteboard.PasteboardType("public.data"), NSPasteboard.PasteboardType("public.file-url")])

        addTemplateButton.image = NSImage(named: NSImage.Name.addTemplate)
        removeTemplateButton.image = NSImage(named: NSImage.Name.removeTemplate)
        
        super.awakeFromNib()
    }
    
    func obtainRows() -> NSArray
    {
        let tempArray : NSMutableArray = NSMutableArray()
        
        SMLog(Preferences.loadTemplatesTablePreferences())
        
        for item in Preferences.loadTemplatesTablePreferences()
        {
            let tempActive : Any? = (item as AnyObject).object(forKey: "active")
            let active: Bool = tempActive as! Bool
            //let active : Int! = (item as AnyObject).object(forKey: "active") as! Int
            
            if (active == true)
            {
                tempArray.add(item)
            }
        }

        return tempArray
    }
    
    @IBAction func resetDefaults(_ sender: AnyObject) {
        
        Preferences.setDefaultValues()
        dataArray = NSMutableArray(array: obtainRows())
        table.reloadData()
        
        SCHEDULE_POSTNOTIFICATION(kUpdateTableFromPreferences, object: nil)
    }
    
    @IBAction func helpTemplatesAction(_ sender: AnyObject) {

        AppDelegate.sharedInstance().showHelpAttached(sender)
    }
    
    @IBAction func removeTemplateAction(_ sender: AnyObject) {
        
        let selectedRow : Int = table.selectedRow
        
        let tempDict : NSDictionary = dataArray[selectedRow] as! NSDictionary
        
        let originalData : NSMutableArray = NSMutableArray(array: Preferences.loadTemplatesTablePreferences())
        let originalIndex : Int = originalData.index(of: tempDict)
        
        let objectItem : NSMutableDictionary = NSMutableDictionary(dictionary: tempDict)
        
        let stringFile : String = objectItem.object(forKey: "templateColumn") as! String
        
        objectItem.setObject(0, forKey: "active" as NSCopying)
        
        dataArray.replaceObject(at: selectedRow, with: objectItem)
        
        originalData.replaceObject(at: originalIndex, with: objectItem)
        
        _ = Preferences.setTemplatesTablePreferences(originalData)

        dataArray = NSMutableArray(array: obtainRows())
        
        table.reloadData()
        
        let fileManager : Foundation.FileManager = Foundation.FileManager.default
        var error : NSError?
        var status : Bool = false
        
        for item in FileManager.listExternalTemplates()
        {
            let itemStr : String = item as! String
            
            if (itemStr.lowercased() == stringFile.lowercased())
            {
                SMLog("archivo: " + itemStr);
                let finalPath : String = FileManager.applicationDirectory().appendingPathComponent(itemStr)
                
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
                    SMLog("no borrado" );
                }

                break
            }
        }
        
        SCHEDULE_POSTNOTIFICATION(kUpdateTableFromPreferences, object: nil)
    }
    
    @IBAction func addButtonAction(_ sender: AnyObject) {
        
        DispatchQueue.main.async(execute: {
            
            let panel : NSOpenPanel = NSOpenPanel()
            
            panel.message = SMLocalizedString("selectFileTemplate")
            panel.allowsOtherFileTypes = false
            panel.isExtensionHidden = false
            panel.canCreateDirectories = false
            panel.canChooseDirectories = false
            panel.title = "Saving as..."
            panel.showsToolbarButton = true
            panel.level = NSWindow.Level(rawValue: Int(CGShieldingWindowLevel()))
            panel.showsResizeIndicator = false
            panel.isAutodisplay = true
            panel.disableSnapshotRestoration()
            panel.allowsMultipleSelection = true
            
            let desktopPath : String = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true)[0] 
            
            panel.directoryURL = URL(fileURLWithPath:desktopPath)
            
            panel.begin { (result : NSApplication.ModalResponse) -> Void in
                
//                if result == NSFileHandlingPanelCancelButton
                if result == NSApplication.ModalResponse.cancel
                {
                
                }
                
//                if (result == NSFileHandlingPanelOKButton)
                if (result == NSApplication.ModalResponse.OK)
                {
                    let urls : [URL] = panel.urls
                    
                    for urlItem in urls {
                        
                        let urlObject : NSURL = NSURL(fileURLWithPath: urlItem.path)
                        
                        if (!self.isDirectory(pathURL: urlObject)) {
                            self.addURLFile(fileURLItem: urlItem)
                        }
                    }
                }
            }
        })
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
            
            _ = Preferences.setTemplatesTablePreferences(templatesArray);
            
            self.dataArray = NSMutableArray(array: self.obtainRows())
            
            self.table.reloadData()
            
            if (self.dataArray.count > 0)
            {
                self.table.scrollRowToVisible(self.dataArray.count - 1)
            }
            
            SCHEDULE_POSTNOTIFICATION(kUpdateTableFromPreferences, object: nil)
        }
    }
    
    // MARK: - NSTableViewDataSource & NSTableViewDelegate methods

    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting?
    {
        let item = NSPasteboardItem()
        item.setString(String(row), forType: NSPasteboard.PasteboardType(rawValue: "public.data"))
        
        return item
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation
    {
        if dropOperation == .above
        {
            return .move
        }
        
        return NSDragOperation()
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
            let pb: NSPasteboard = info.draggingPasteboard()

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
                    
                    let object : NSMutableDictionary = dataArray[finalOldIndex] as! NSMutableDictionary
                    
                    let tempArray : NSMutableArray = NSMutableArray(array: Preferences.loadTemplatesTablePreferences())
                    
                    let originalNewIndex : Int = tempArray.index(of: dataArray[finalNewIndex] as! NSMutableDictionary)
                    let originalOldIndex : Int = tempArray.index(of: dataArray[finalOldIndex] as! NSMutableDictionary)
                    
                    tempArray.removeObject(at: originalOldIndex)
                    tempArray.insert(object, at: originalNewIndex)
                    
                    _ = Preferences.setTemplatesTablePreferences(tempArray)
                    
                    dataArray.removeObject(at: finalOldIndex)
                    dataArray.insert(object, at: finalNewIndex)
                }
                else
                {
                    let finalOldIndex : Int = oldIndex
                    let finalNewIndex : Int = row + newIndexOffset
                    
                    tableView.moveRow(at: finalOldIndex, to: finalNewIndex)
                    newIndexOffset += 1
                    SMLog("old index: \(finalOldIndex) new index: \(finalNewIndex)")
                    
                    let object : NSMutableDictionary = dataArray[finalOldIndex] as! NSMutableDictionary
                    
                    let tempArray : NSMutableArray = NSMutableArray(array: Preferences.loadTemplatesTablePreferences())
                    
                    let originalNewIndex : Int = tempArray.index(of: dataArray[finalNewIndex] as! NSMutableDictionary)
                    let originalOldIndex : Int = tempArray.index(of: dataArray[finalOldIndex] as! NSMutableDictionary)
                    
                    tempArray.removeObject(at: originalOldIndex)
                    tempArray.insert(object, at: originalNewIndex)
                    
                    _ = Preferences.setTemplatesTablePreferences(tempArray)
                    
                    dataArray.removeObject(at: finalOldIndex)
                    dataArray.insert(object, at: finalNewIndex)
                }
            }
            
            tableView.endUpdates()
        }
        
        tableView.reloadData()

        SCHEDULE_POSTNOTIFICATION(kUpdateTableFromPreferences, object: nil)
        
        return true
    }
    
    func isDirectory(pathURL: NSURL) -> Bool {
        
        var isDirectory : ObjCBool = false
        let fileExistsAtPath : Bool  = Foundation.FileManager.default.fileExists(atPath: pathURL.path!, isDirectory: &isDirectory)
        
        if (fileExistsAtPath)
        {
            if isDirectory.boolValue
            {
                // It's a Directory.
                return true
            }
        }
        
        return false
    }
    
//    func performDragOperation(_ sender: NSDraggingInfo) -> Bool
//    {
//        let board: NSArray = (sender.draggingPasteboard().propertyList(forType: NSPasteboard.PasteboardType(rawValue: "public.file-url")) as? NSArray)!
//
//        if (board.count > 0)
//        {
//            return true
//        }
//        return false
//    }
    
    func numberOfRows(in aTableView: NSTableView) -> Int
    {
        let numberOfRows : Int = dataArray.count
        return numberOfRows
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any?
    {
        let object = dataArray[row] as! NSMutableDictionary
        
        if ((tableColumn!.identifier).rawValue == "enableColumn")
        {
            let status : Bool = object[tableColumn!.identifier] as! Bool
            
            return status
        }
        else if ((tableColumn!.identifier).rawValue == "templateColumn")
        {
            return object[tableColumn!.identifier] as? String!
        }
        else
        {
            let dict : NSDictionary = dataArray.object(at: row) as! NSDictionary
            
            let value : String = dict.object(forKey: "templateColumn") as! String
            var components : [String] = value.components(separatedBy: ".") as [String]
            
            let image : NSImage = NSWorkspace.shared.icon(forFileType: components[1])
            
            return image
        }
    }
    
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int)
    {
        if (tableColumn?.identifier.rawValue == "enableColumn")
        {
            //let objectReplace : NSMutableDictionary = dataArray[row] as! NSMutableDictionary
            let temp : Any? = dataArray.object(at: row)
 
            let temp2 : [String: NSObject] = temp as! [String : NSObject]
    
            let objectReplace : NSMutableDictionary = NSMutableDictionary()

            objectReplace.setObject(temp2["templateColumn"] as! String, forKey: "templateColumn" as NSCopying)
            objectReplace.setObject(temp2["enableColumn"] as! Bool, forKey: "enableColumn" as NSCopying)
            objectReplace.setObject(temp2["active"] as! Bool, forKey: "active" as NSCopying)
            
            //let objectReplace : NSMutableDictionary = temp2 as! NSMutableDictionary
   
            let arrayItems : NSArray = Preferences.loadTemplatesTablePreferences()
            
            let originalData : NSMutableArray = NSMutableArray()
            originalData.addObjects(from: arrayItems as! [Any])
 
            let originalIndex : Int = originalData.index(of: objectReplace)
        
            let objectItem : NSMutableDictionary = NSMutableDictionary(dictionary: objectReplace)
            
            let status : Bool = object as! Bool
   
            objectItem.setObject(status, forKey: (tableColumn?.identifier)! as NSCopying)
            
            dataArray.replaceObject(at: row, with: objectItem)
            
            originalData.replaceObject(at: originalIndex, with: objectItem)
      
            _ = Preferences.setTemplatesTablePreferences(originalData)
            
            tableView.reloadData()
            
            SCHEDULE_POSTNOTIFICATION(kUpdateTableFromPreferences, object: nil)
        }
    }
    
    //MARK: - NSNotification methods
    
    func eventUpdateSettingsCloud(_ notification : Notification)
    {
        if (self.table == nil)
        {
            return
        }
        
        self.dataArray = NSMutableArray(array: self.obtainRows())
        
        self.table.reloadData()
        SCHEDULE_POSTNOTIFICATION(kUpdateTableFromPreferences, object: nil)
    }
    
    // MARK: - MASPreferencesViewController
    
    override var identifier: NSUserInterfaceItemIdentifier? {
        
        get {
            return NSUserInterfaceItemIdentifier(SMLocalizedString("advanced"))
        }
        
        set {
            super.identifier = newValue
        }
    }
    
    var toolbarItemImage: NSImage {
        return NSImage(named:NSImage.Name.advanced)!
    }
    
    var toolbarItemLabel: String {
        
        return SMLocalizedString("advanced")
    }
}
