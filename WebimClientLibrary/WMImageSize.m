//
//  WMImageSize.m
//  WebimClientLibrary
//
//  Created by Michael Rublev on 15/09/15.
//  Copyright (c) 2015 Webim.ru. All rights reserved.
//


#import "WMImageSize.h"


@implementation WMImageSize

+ (WMImageSize *)createWithObject:(id)object {
    return [[WMImageSize alloc] initWithObject:object];
}

- (WMImageSize *)initWithObject:(NSDictionary *)object {
    if ((self = [super init])) {
        _width = [object[@"width"] integerValue];
        _height = [object[@"height"] integerValue];
    }
    
    return self;
}

@end
