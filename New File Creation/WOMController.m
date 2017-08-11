//
//  WOMController.m
//  PopoverMenulet
//
//  Created by Julián Romero on 10/26/11.
//  Copyright (c) 2011 Wuonm Web Services S.L. All rights reserved.
//

#import "WOMController.h"
#import "WOMMenulet.h"
#import "WOMPopoverController.h"
#import "Macros-objc.h"

@interface WOMController ()

@property NSString *droppedDirectory; /* FIXME: temporary */

@end

@implementation WOMController

@synthesize viewController;
@synthesize item;

- (instancetype)init
{
    self = [super init];
    NSAssert(self, @"Fatal: error creating WOMController");

    CGFloat thickness = [[NSStatusBar systemStatusBar] thickness];
    self.item = [[NSStatusBar systemStatusBar] statusItemWithLength:thickness];
    self.menulet = [[WOMMenulet alloc] initWithFrame:(NSRect){.size={thickness, thickness}}]; /* square item */
    self.menulet.delegate = self;
    [self.item setView:self.menulet];
    [self.item setHighlightMode:NO]; /* blue background when clicked ? */

    return self;
}

#pragma mark - Mouse handling 

- (void)leftButtonHandler
{
    self.active = ! self.active;
    if (self.isActive)
        [self openPopover];
    else
        [self closePopover];
}

- (void)rightButtonHandler
{
    [self leftButtonHandler];
}

#pragma mark - Popover

- (void)closePopover
{
    self.active = NO;
    [self.viewController.popover performClose:self];
    [self.menulet setNeedsDisplay:YES];
}

- (void)openPopover
{
    [NSApp activateIgnoringOtherApps:YES];
    
    [self _setup];
    [self.viewController.popover showRelativeToRect:[self.menulet frame]
                                             ofView:self.menulet
                                      preferredEdge:NSMinYEdge];
}

#pragma mark - WOMMenuletDelegate

//- (NSString *)activeImageName
//{
//    BOOL isDarkMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDarkMode"];
//    
//    if (isDarkMode)
//    {
//        return @"icon-menulet-white";
//    }
//    
//    return @"icon-menulet";
//}
//
//- (NSString *)inactiveImageName
//{
//    BOOL isDarkMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"isDarkMode"];
//    
//    if (isDarkMode)
//    {
//        return @"icon-menulet-white";
//    }
//    
//    return @"icon-menulet";
//}

- (void)menuletClicked:(MouseButton)mouseButton
{
    SMLog(@"Menulet clicked");
    if (mouseButton == LeftButton)
    {
        [self leftButtonHandler];
    }
    else
    {
        [self rightButtonHandler];
    }
}

- (NSArray *)dragTypes
{
    return @[NSFilenamesPboardType, NSURLPboardType, NSStringPboardType];
}

- (void)didDropFileItems:(NSArray *)items
{
    SMLog(@"Dropped: %@", items);
    self.droppedDirectory = [items firstObject];
}

- (void)didDropURL:(NSURL *)url
{
    SMLog(@"Dropped: %@", url);
    /* FIXME: folder action */
}

- (void)didDropText:(NSString *)text
{
    SMLog(@"Dropped: %@", text);
    /* FIXME: folder action */
}

#pragma mark - WOMPopoverDelegate

- (void)popover:(id)popover didClickButtonForAction:(NSUInteger)action
{
    SMLog(@"did click button for action %@", @(action));
    [self closePopover];
}

- (NSString *)iconsDirectory
{
    return self.droppedDirectory;
}

#pragma mark - Private

- (void)_setup
{
    if (!self.viewController)
    {
        self.viewController = [[WOMPopoverController alloc] init];
        self.viewController.delegate = self;
    }
}

- (void)eventNotifyDarkModeChanged:(NSNotification *)notification
{
    
}

@end
