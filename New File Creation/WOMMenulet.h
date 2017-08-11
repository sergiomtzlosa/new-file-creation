//
//  WOMMenulet.h
//  PopoverMenulet
//
//  Created by Julián Romero on 10/26/11.
//  Copyright (c) 2011 Wuonm Web Services S.L. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

typedef enum {
    UnknownButton,
    LeftButton = NSLeftMouseDown,
    RightButton = NSRightMouseDown,
    OtherButton
} MouseButton;

@protocol WOMMenuletDelegateImages <NSObject>
@optional

- (NSString *)activeImageName;
- (NSString *)inactiveImageName;

@end

@protocol WOMMenuletDelegate <NSObject>
@optional

- (BOOL)isActive;
- (void)menuletClicked:(MouseButton)mouseButton;

- (NSArray *)dragTypes;
- (void)didDropFileItems:(NSArray *)items;
- (void)didDropURL:(NSURL *)url;
- (void)didDropText:(NSString *)text;

@end

@interface WOMMenulet : NSView

@property (nonatomic, weak) id<WOMMenuletDelegate> delegate;
@property (nonatomic, weak) id<WOMMenuletDelegateImages> imagesDelegate;

@end
