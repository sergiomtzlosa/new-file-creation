//
//  WOMController.h
//  PopoverMenulet
//
//  Created by Julián Romero on 10/26/11.
//  Copyright (c) 2011 Wuonm Web Services S.L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WOMMenulet.h"
#import "WOMPopoverController.h"

@interface WOMController : NSWindow <WOMPopoverDelegate, WOMMenuletDelegate>

@property (nonatomic, strong) WOMPopoverController *viewController;     /** popover content view controller */
@property (nonatomic, strong) WOMMenulet *menulet;                      /** menu bar icon view */
@property (nonatomic, strong) NSStatusItem *item;                       /** status item */
@property (getter = isActive) BOOL active;          /** menu bar active */

- (void)eventNotifyDarkModeChanged:(NSNotification *)notification;
- (void)closePopover;
- (void)rightButtonHandler;
- (void)leftButtonHandler;
- (void)openPopover;

@end
