//
//  WMOperator+Private.h
//  Webim-Client
//
//  Created by Oleg Bogumirsky on 9/5/13.
//  Copyright (c) 2013 WEBIM.RU Ltd. All rights reserved.
//


#import "WMOperator.h"


@interface WMOperator (Private)

- (WMOperator *)initWithObject:(NSDictionary *)object;
- (void)updateWithObject:(NSDictionary *)object;

@end
