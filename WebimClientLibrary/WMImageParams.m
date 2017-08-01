//
//  WMImageParams.m
//  WebimClientLibrary
//
//  Created by Michael Rublev on 15/09/15.
//  Copyright (c) 2015 Webim.ru. All rights reserved.
//


#import "WMImageParams.h"

#import "WMImageSize.h"


@implementation WMImageParams

+ (WMImageParams *)createWithObject:(id)object {
    return [[WMImageParams alloc] initWithObject:object];
}

- (instancetype)initWithObject:(NSDictionary *)object {
    if ((self = [super init])) {
        _size = [WMImageSize createWithObject:object[@"size"]];
    }
    
    return self;
}

@end
