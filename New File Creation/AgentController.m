//
//  AgentController.m
//  New File Creation
//
//  Created by sid on 07/08/15.
//  Copyright (c) 2015 com.sergiomtzlosa.filecreation. All rights reserved.
//

#import "AgentController.h"
#import <ServiceManagement/ServiceManagement.h>
#import <QuartzCore/QuartzCore.h>

@implementation AgentController

+ (BOOL)checkLoginForIdentifier:(NSString *)applicationIdentifer
{
    NSArray *jobs = (__bridge NSArray *)SMCopyAllJobDictionaries(kSMDomainUserLaunchd);
    
    if (jobs == nil)
    {
        return NO;
    }
    
    if ([jobs count] == 0)
    {
        CFRelease((CFArrayRef)jobs);
        return NO;
    }
    
    BOOL onDemand = NO;
    
    for (NSDictionary *job in jobs)
    {
        if ([applicationIdentifer isEqualToString:[job objectForKey:@"Label"]])
        {
            onDemand = [[job objectForKey:@"OnDemand"] boolValue];
            break;
        }
    }
    
    CFRelease((CFArrayRef)jobs);
    return onDemand;
}

+ (BOOL)enableLoginItemForIdentifier:(NSString *)applicationIdentifier forStatus:(BOOL)status
{
    return SMLoginItemSetEnabled((__bridge CFStringRef)applicationIdentifier, status);
}

@end
