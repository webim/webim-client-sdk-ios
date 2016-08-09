//
//  WMUIDGenerator.m
//  WebimClientLibrary
//
//  Created by Michael Rublev on 17/09/15.
//  Copyright © 2015 Webim.ru. All rights reserved.
//

#import "WMUIDGenerator.h"

@implementation WMUIDGenerator

+ (NSString *)generateUID {
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    NSString *returnValue = (__bridge NSString *)uuidStringRef;
    returnValue = [returnValue stringByReplacingOccurrencesOfString:@"-" withString:@""];
    CFRelease(uuidRef);
    CFRelease(uuidStringRef);
    return returnValue;
}

@end
