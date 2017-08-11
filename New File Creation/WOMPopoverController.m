//
//  WOMPopoverController.m
//  PopoverMenulet
//
//  Created by Julián Romero on 10/26/11.
//  Copyright (c) 2011 Wuonm Web Services S.L. All rights reserved.
//

#import "WOMPopoverController.h"
#import "WOMMenulet.h"
#import "Macros-objc.h"

@interface WOMPopoverController ()
@end

@implementation WOMPopoverController
@synthesize popover;

- (instancetype)init
{
    self = [super initWithNibName:@"WOMPopover" bundle:nil];
    NSAssert(self, @"Fatal: error loading nib WOMPopover");

    self.popover = [[NSPopover alloc] init];
    self.popover.contentViewController = self;
    [self.popover.contentViewController.view setAppearance:[NSAppearance appearanceNamed:NSAppearanceNameAqua]];
    
    SCHEDULE_POSTNOTIFICATION(kPopOverDidLoad, self);
    
    return self;
}

- (void) mouseDown: (NSEvent*) theEvent
{
    SMLog(@"Click!");
}

- (void) rightMouseDown:(NSEvent*) theEvent
{
    SMLog(@"DERECHA PULSADA!");
}

@end
