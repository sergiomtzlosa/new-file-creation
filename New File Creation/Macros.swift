//
//  Macros.swift
//  New File Creation
//
//  Created by sid on 04/08/15.
//  Copyright (c) 2015 com.sergiomtzlosa.filecreation. All rights reserved.
//

import Foundation

let kPopOverDidLoad = "popover-did-load"
let kFinderSyncOption = "findersync-menulet"
let kChangeInterfaceNotification = "AppleInterfaceThemeChangedNotification"
let kUpdateTableFromPreferences = "update-table-from-preferences"
let kUpdateSettingCloud = "update-settings-icloud"

let kGroupPreference = "9Z3J82KRJR.com.sergiomtzlosa.filecreation"

func SMLocalizedString(_ string: String!) -> String
{
    return NSLocalizedString(string, comment: "")
}

func currentLanguage() -> String
{
    let preferredLanguage = Locale.preferredLanguages[0] 
    
    return preferredLanguage.lowercased()
}

func SCHEDULE_POSTNOTIFICATION(_ name: String!, object: AnyObject?)
{
    DispatchQueue.main.async { () -> Void in
        
        SMLog("se envia la notificacion")
        NotificationCenter.default.post(name: Notification.Name(rawValue: name), object: object)
    }
}

// Macro para registrar una clase para que se reciba la notificacion broadcast
func REGISTER_NOTIFICATION(_ className: AnyObject, selector: Selector, name: String?)
{
    if (className.responds(to: selector))
    {
        SMLog("registra a la notificacion")
        NotificationCenter.default.addObserver(className, selector: selector, name: name.map { NSNotification.Name(rawValue: $0) }, object: nil)
    }
    else
    {
        SMLog("No registra a la notificacion" )
    }
}

func REGISTER_NOTIFICATION(_ className: AnyObject, selector: Selector, name: String?, object: AnyObject?)
{
    if (className.responds(to: selector))
    {
        SMLog("registra a la notificacion")
        NotificationCenter.default.addObserver(className, selector: selector, name: name.map { NSNotification.Name(rawValue: $0) }, object: object)
    }
    else
    {
        SMLog("No registra a la notificacion")
    }
}

func REGISTER_DISTRIBUTED_NOTIFICATION(_ className: AnyObject, selector: Selector, name: String?)
{
    if (className.responds(to: selector))
    {
        SMLog("registra a la notificacion")
        DistributedNotificationCenter.default().addObserver(className, selector: selector, name: name.map { NSNotification.Name(rawValue: $0) }, object: nil)
    }
    else
    {
        SMLog("No registra a la notificacion")
    }
}


func REMOVE_NOTIFICATION(_ className: AnyObject)
{
    NotificationCenter.default.removeObserver(className)
}

func REMOVE_NOTIFICATION_FLAG(_ className: AnyObject, name: String?, object: AnyObject?)
{
    NotificationCenter.default.removeObserver(className, name: name.map { NSNotification.Name(rawValue: $0) }, object: object)
}