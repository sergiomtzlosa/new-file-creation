//
//  SMLog.m
//

#import "SMLog.h"

@implementation SMLog

+ (void)log:(NSString *)strLog debug:(BOOL)debug
{
    if (debug)
        NSLog(@"%@", strLog);
}

@end



