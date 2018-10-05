//
//  CloudSyncViewController.swift
//  New File Creation
//
//  Created by sid on 05/09/15.
//  Copyright (c) 2015 com.sergiomtzlosa.filecreation. All rights reserved.
//

import Foundation

class CloudSyncViewController : NSViewController, MASPreferencesViewController
{
    @IBOutlet var helpTipLabel: NSTextField!
    @IBOutlet var uploadTemplatesButton: NSButton!
    @IBOutlet var downloadTemplatesButton: NSButton!
    
    var metadataQuery : NSMetadataQuery!
    var attachedWindowHelp : MAAttachedWindow!
    
    override func awakeFromNib() {
        
        helpTipLabel.stringValue = SMLocalizedString("tipHelpCloud")
        uploadTemplatesButton.title = SMLocalizedString("uploadButtonTitle")
        downloadTemplatesButton.title = SMLocalizedString("downloadButtonTitle")
        
//        self.resignFirstResponder()
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        
        self.metadataQuery = NSMetadataQuery()
        
        metadataQuery.predicate = NSPredicate(format: "%K LIKE '*'", NSMetadataItemFSNameKey)
        metadataQuery.searchScopes = NSArray(arrayLiteral: NSMetadataQueryUbiquitousDocumentsScope) as [AnyObject]
        
        registerNotifications()
        
        super.viewDidLoad()
    }
    
    func registerNotifications()
    {
        REGISTER_NOTIFICATION(self, selector: #selector(CloudSyncViewController.queryDidReceiveNotification(_:)), name: NSNotification.Name.NSMetadataQueryDidFinishGathering.rawValue, object: self.metadataQuery)
        
        REGISTER_NOTIFICATION(self, selector: #selector(CloudSyncViewController.queryDidReceiveNotification(_:)), name: NSNotification.Name.NSMetadataQueryDidUpdate.rawValue, object: self.metadataQuery)
        
        self.metadataQuery.start()
    }
    
    @objc func queryDidReceiveNotification(_ notification : Notification)
    {
//        metadataQuery.disableUpdates()
        
//        var results : NSArray = self.metadataQuery.results
    
//        SMLog(results)
        
//        for item in results
//        {
//            var filename : NSString = item.valueForAttribute(NSMetadataItemDisplayNameKey) as! NSString
//            var filesize : NSNumber = item.valueForAttribute(NSMetadataItemFSSizeKey) as! NSNumber
//            var updated : NSDate = item.valueForAttribute(NSMetadataItemFSContentChangeDateKey) as! NSDate
//            
//            SMLog("\(filename) (\(filesize) bytes, updated \(updated))");
//        }
        
//        registerNotifications()
//        
//        metadataQuery.enableUpdates()
    }
    
    override init(nibName nibNameString: NSNib.Name?, bundle bundleItem: Bundle?)
    {
        super.init(nibName: nibNameString, bundle: bundleItem)
    }
    
    override func viewWillAppear() {

        super.viewWillAppear()
    }
    
    override func viewWillDisappear() {
        
        removeHelpWindow()
        
        super.viewWillDisappear()
    }
    
    @IBAction func showHelpCloud(_ sender: AnyObject) {
        
        if (attachedWindowHelp == nil)
        {
            let helpButton : NSButton = sender as! NSButton
            
            let buttonPoint : NSPoint  = NSMakePoint(helpButton.frame.origin.x + 4, helpButton.frame.origin.y + 15);
            
            attachedWindowHelp = MAAttachedWindow(view: createHelpView(), attachedTo: buttonPoint, in: helpButton.window, onSide: MAPositionRight, atDistance: 25.0)
            
            attachedWindowHelp.setBorderColor(NSColor.white)
            attachedWindowHelp.setBackgroundColor(NSColor.black)
            attachedWindowHelp.setViewMargin(10.0)
            attachedWindowHelp.setBorderWidth(1.0)
            attachedWindowHelp.setCornerRadius(8.0)
            attachedWindowHelp.setHasArrow(1.0)
            attachedWindowHelp.setArrowBaseWidth(35.0)
            attachedWindowHelp.setArrowHeight(15.0)
            
            attachedWindowHelp.alphaValue = 0.0
            AppDelegate.preferencesWindow().addChildWindow(attachedWindowHelp!, ordered:NSWindow.OrderingMode.above)
            attachedWindowHelp.animator().alphaValue = 1.0
        }
        else
        {
            removeHelpWindow()
        }
    }
    
    func removeHelpWindow()
    {
        if (attachedWindowHelp != nil)
        {
            attachedWindowHelp.alphaValue = 1.0
            AppDelegate.preferencesWindow().removeChildWindow(attachedWindowHelp!)
            attachedWindowHelp.animator().alphaValue = 0.0
            attachedWindowHelp.orderOut(self)
            attachedWindowHelp = nil;
        }
    }
    
    func createHelpView() -> NSTextView
    {
        let textView : NSTextView = NSTextView(frame: CGRect.zero)
        
        textView.maxSize = NSMakeSize(CGFloat.greatestFiniteMagnitude, CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.autoresizingMask = NSView.AutoresizingMask.width
        textView.textContainer?.widthTracksTextView = true
        textView.string = SMLocalizedString("syncCloudTip")
        textView.backgroundColor = NSColor.clear
        textView.textColor = NSColor.white
        textView.isHorizontallyResizable = true
        
        let size : NSRect = SMObject.calculateSizeForText(textView.string as NSString, textView: textView)
        
        textView.frame = size
        
        return textView
    }
    
    @IBAction func downloadFromCloud(_ sender: AnyObject) {
        
        let modalWindow = SMSheetWindow(windowNibName: NSNib.Name(rawValue: "SMSheetWindow"))
        modalWindow.uploading = false
        modalWindow.beginSheet(AppDelegate.preferencesWindow())
        
        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default);
        queue.async(execute: {
            
            if (CloudManager.checkCloudAvailable())
            {
                let folderPath : String = FileManager.applicationDirectory() as String
                let destionationPath : URL = URL(fileURLWithPath: "\(folderPath)/\(fileArchive)")
                
                // download from iCloud
                let downloaded : Bool = self.downloadTemplatesFromCloud(destionationPath)
                
                DispatchQueue.main.async(execute: {
                    
                    modalWindow.endSheet()
                    
                    if downloaded
                    {
                        self.cloudSimpleDialogChoose(SMLocalizedString("warning"), message: SMLocalizedString("positiveDownload"))
                        SMLog("downloaded here!")
                        
                        SCHEDULE_POSTNOTIFICATION(kUpdateSettingCloud, object: nil)
                    }
                    else
                    {
                        self.cloudSimpleDialogChoose(SMLocalizedString("warning"), message: SMLocalizedString("errorDownload"))
                        SMLog("not downloaded here!")
                    }
                    
                    self.metadataQuery.start()
                })
            }
            else
            {
                DispatchQueue.main.async(execute: {
                    
                    modalWindow.endSheet()
                    self.cloudDialogChoose(SMLocalizedString("warning"), message: SMLocalizedString("icloudNotFetch"))
                })
            }
        })
    }
    
    @IBAction func uploadToCloud(_ sender: AnyObject) {
        
        let modalWindow = SMSheetWindow(windowNibName: NSNib.Name(rawValue: "SMSheetWindow"))
        modalWindow.uploading = true
        modalWindow.beginSheet(AppDelegate.preferencesWindow())
        
        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default);
        queue.async(execute: {
            
            if (CloudManager.checkCloudAvailable())
            {
                let destionationPath : URL = CloudManager.cloudPath! as URL
                
                // upload to iCloud
                let uploaded : Bool = self.uploadTemplatesToCloud(destionationPath)
                
                DispatchQueue.main.async(execute: {
                    
                    modalWindow.endSheet()
                    
                    if uploaded
                    {
                        self.cloudSimpleDialogChoose(SMLocalizedString("warning"), message: SMLocalizedString("positiveUploaded"))
                        SMLog("uploaded here!")
                    }
                    else
                    {
                        self.cloudSimpleDialogChoose(SMLocalizedString("warning"), message: SMLocalizedString("notUploaded"))
                        SMLog("not uploaded here!")
                    }

                    self.metadataQuery.start()
                })
            }
            else
            {
                DispatchQueue.main.async(execute: {
                    
                    modalWindow.endSheet()
                    self.cloudDialogChoose(SMLocalizedString("warning"), message: SMLocalizedString("icloudNotFetch"))
                })
            }
        })
    }
    
    @discardableResult
    func cloudSimpleDialogChoose(_ title: String, message: String) -> Bool
    {
        let alertDialog: NSAlert = NSAlert()
        
        alertDialog.messageText = title
        alertDialog.informativeText = message
        alertDialog.alertStyle = NSAlert.Style.warning
        
        alertDialog.addButton(withTitle: SMLocalizedString("OK"))
  
        let result = alertDialog.runModal()
        
        if result == NSApplication.ModalResponse.alertFirstButtonReturn
        {
            return true
        }
        
        return false
    }
    
    @discardableResult
    func cloudDialogChoose(_ title: String, message: String) -> Bool
    {
        let alertDialog: NSAlert = NSAlert()
        
        alertDialog.messageText = title
        alertDialog.informativeText = message
        alertDialog.alertStyle = NSAlert.Style.warning
        
        alertDialog.addButton(withTitle: SMLocalizedString("showIcloudPreferences"))
        alertDialog.addButton(withTitle: SMLocalizedString("cancel"))
        
        let result = alertDialog.runModal()
        
        if result == NSApplication.ModalResponse.alertFirstButtonReturn
        {
            Utils.openCloudPreferences()
            return true
        }
        
        return false
    }
    
    func downloadTemplatesFromCloud(_ destination: URL) -> Bool
    {
        // download from iCloud
        return CloudManager.downloadFromCloud(destination)
    }
    
    func uploadTemplatesToCloud(_ destination: URL) -> Bool
    {
        let zipPath : String = CloudManager.zipCloudFiles()
        
        // upload to iCloud
        return CloudManager.uploadToCloud(zipPath, destination: destination)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("NSCoding not supported")
    }
    
    // MARK: - MASPreferencesViewController
    
    override var identifier: NSUserInterfaceItemIdentifier?
    {
        get {
            return NSUserInterfaceItemIdentifier(SMLocalizedString("icloud"))
        }
        
        set {
            super.identifier = newValue
        }
    }
    
    var toolbarItemImage: NSImage
    {
        return NSImage(named:NSImage.Name.network)!
    }
    
    var toolbarItemLabel: String
    {
        return SMLocalizedString("icloud")
    }
}
