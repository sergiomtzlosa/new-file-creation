//
//  Volumes.h
//  New File Creation
//
//  Created by sid on 17/08/15.
//  Copyright (c) 2015 com.sergiomtzlosa.filecreation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Volumes : NSObject

+ (NSArray *)mountedVolumes;

+ (NSArray *)mountedAllVolumes;

@end
