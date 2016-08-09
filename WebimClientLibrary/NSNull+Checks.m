//
//  NSNull+Checks.m
//  WebimClientLibrary
//
//  Created by Michael Rublev on 26/10/15.
//  Copyright © 2015 Webim.ru. All rights reserved.
//

#import "NSNull+Checks.h"

@implementation NSNull (Checks)

+ (id)valueOf:(id)object {
    if (object == nil || [object isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return object;
}

@end
