//
//  Volumes.m
//  New File Creation
//
//  Created by sid on 17/08/15.
//  Copyright (c) 2015 com.sergiomtzlosa.filecreation. All rights reserved.
//

#import "Volumes.h"
#include <AppKit/AppKit.h>
#import <DiskArbitration/DiskArbitration.h>

@implementation Volumes
#ifndef __clang_analyzer__
+ (NSArray *)mountedVolumes
{
    NSArray *mountedRemovableMedia = [[NSFileManager defaultManager] mountedVolumeURLsIncludingResourceValuesForKeys:nil
                                                                                                             options:NSVolumeEnumerationSkipHiddenVolumes];
    
    NSMutableArray *result = [NSMutableArray array];
    
    for (NSURL *volURL in mountedRemovableMedia)
    {
        int err = 0;
        DADiskRef disk;
        DASessionRef session;
        CFDictionaryRef descDict;
        session = DASessionCreate(NULL);
        
        if (session == NULL)
        {
            err = EINVAL;
        }
        
        if (err == 0)
        {
            disk = DADiskCreateFromVolumePath(NULL,session,(__bridge CFURLRef)volURL);
            
            if (session == NULL)
            {
                err = EINVAL;
            }
        }
        
        if (err == 0)
        {
            descDict = DADiskCopyDescription(disk);
            
            if (descDict == NULL)
            {
                err = EINVAL;
            }
        }

        if (err == 0)
        {
            CFTypeRef mediaEjectableKey = CFDictionaryGetValue(descDict,kDADiskDescriptionMediaEjectableKey);
            CFTypeRef deviceProtocolName = CFDictionaryGetValue(descDict,kDADiskDescriptionDeviceProtocolKey);
            
            if (mediaEjectableKey != NULL)
            {
                BOOL op = CFEqual(mediaEjectableKey, CFSTR("0")) || CFEqual(deviceProtocolName, CFSTR("USB"));
                
                if (op)
                {
                    [result addObject:volURL];
                }
            }
        }

        if (descDict != NULL)
        {
            CFRelease(descDict);
        }

        if (disk != NULL)
        {
            CFRelease(disk);
        }
        
        if (session != NULL)
        {
            CFRelease(session);
        }

    }
    
    return (NSArray *)result;
}

+ (NSArray *)mountedAllVolumes
{
    NSArray* listOfMedia = [[NSWorkspace sharedWorkspace] mountedLocalVolumePaths];
    
    NSMutableArray *final = [[NSMutableArray alloc] init];
    
    for (NSString* volumePath in listOfMedia)
    {
        NSURL *urlVolume = [[NSURL alloc] initFileURLWithPath:volumePath];
        
        [final addObject:urlVolume];
    }
    
    return (NSArray *)final;
}
#endif
@end
