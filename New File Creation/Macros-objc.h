//
//  Macros-objc.h
//  New File Creation
//
//  Created by sid on 07/08/15.
//  Copyright (c) 2015 com.sergiomtzlosa.filecreation. All rights reserved.
//

#import "SMLog.h"

// Macro para enviar una notificacion broadcast
#define SCHEDULE_POSTNOTIFICATION(NAME, OBJECT) \
    dispatch_async(dispatch_get_main_queue(),^{ \
        SMLog(@"se envia la notificacion"); \
        [[NSNotificationCenter defaultCenter] postNotificationName:NAME object:OBJECT]; \
    });

// Macro para registrar una clase para que se reciba la notificacion broadcast
#define REGISTER_NOTIFICATION(CLASS, SELECTOR, NAME) \
    if ([CLASS respondsToSelector:SELECTOR]) { \
        SMLog(@"registra a la notificacion"); \
        [[NSNotificationCenter defaultCenter] removeObserver:CLASS \
                                                        name:NAME \
                                                      object:OBJECT]; \
        [[NSNotificationCenter defaultCenter] addObserver:CLASS \
                                                 selector:SELECTOR \
                                                     name:NAME \
                                                   object:nil]; \
    } else { \
        SMLog(@"No registra a la notificacion"); \
    }

#define REMOVE_NOTIFICATION(CLASS) [[NSNotificationCenter defaultCenter] removeObserver:CLASS];

#define REMOVE_NOTIFICATION_FLAG(CLASS, NAME, OBJECT) \
    [[NSNotificationCenter defaultCenter] removeObserver:CLASS \
                                                    name:NAME \
                                                  object:OBJECT];

#define kPopOverDidLoad @"popover-did-load"
