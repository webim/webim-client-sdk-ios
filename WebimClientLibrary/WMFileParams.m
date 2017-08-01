//
//  WMFileParams.m
//  WebimClientLibrary
//
//  Created by Michael Rublev on 15/09/15.
//  Copyright (c) 2015 Webim.ru. All rights reserved.
//


#import "WMFileParams.h"

#import "WMImageParams.h"


@implementation WMFileParams

+ (WMFileParams *)createWithObject:(id)object {
    return [[WMFileParams alloc] initWithObject:object];
}

- (WMFileParams *)initWithObject:(NSDictionary *)object {
    if ((self = [super init])) {
        self.size = [object[@"size"] unsignedIntegerValue];
        self.guid = object[@"guid"];
        self.filename = object[@"filename"];
        self.contentType = object[@"content_type"];
        self.imageParams = [WMImageParams createWithObject:object[@"image"]];
    }
    
    return self;
}

@end
