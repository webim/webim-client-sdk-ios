//
//  WMOperator+Private.m
//  Webim-Client
//
//  Created by Oleg Bogumirsky on 9/5/13.
//  Copyright (c) 2013 WEBIM.RU Ltd. All rights reserved.
//


#import "WMOperator+Private.h"

#import "NSNull+Checks.h"


@implementation WMOperator (Private)

- (WMOperator *)initWithObject:(NSDictionary *)object {
    if ((self = [super init])) {
        [self updateWithObject:object];
    }
    
    return self;
}

- (void)updateWithObject:(NSDictionary *)object {
    self.name = [NSNull valueOf:object[@"fullname"]];
    self.avatarPath = [NSNull valueOf:object[@"avatar"]];
    
    id operatorID = [NSNull valueOf:object[@"id"]];
    if ([operatorID isKindOfClass:[NSString class]]) {
        self.uid = operatorID;
    } else if ([operatorID isKindOfClass:[NSNumber class]]) {
        self.uid = [operatorID stringValue];
    }
}

@end
