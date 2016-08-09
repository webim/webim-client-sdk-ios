//
//  WMImageSize.h
//  WebimClientLibrary
//
//  Created by Michael Rublev on 15/09/15.
//  Copyright (c) 2015 Webim.ru. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WMImageSize : NSObject

@property (nonatomic, assign) NSInteger width;

@property (nonatomic, assign) NSInteger height;


+ (WMImageSize *)createWithObject:(id)object;

@end
