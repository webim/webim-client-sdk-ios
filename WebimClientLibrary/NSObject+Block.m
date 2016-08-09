//
//  NSObject+Block.m
//
//
//
//

#import "NSObject+Block.h"

@implementation NSObject (Block)

+ (void)dispatchSyncOnMainThreadBlock:(void (^)(void))block {
    if (block == nil) {
        return;
    }
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

+ (void)dispatchAfterDelay:(NSTimeInterval)delay block:(void (^)(void))block {
    if (block == nil) {
        return;
    }
    dispatch_time_t delta = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
    dispatch_after(delta, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

+ (void)dispatchOnMainThreadAfterDelay:(NSTimeInterval)delay block:(void (^)(void))block {
    [self dispatchAfterDelay:delay block:^{
        [NSObject dispatchSyncOnMainThreadBlock:block];
    }];
}

- (void)dispatchSyncOnMainThreadBlock:(void (^)(void))block {
    [NSObject dispatchSyncOnMainThreadBlock:block];
}

- (void)dispatchAfterDelay:(NSTimeInterval)delay block:(void (^)(void))block {
    [NSObject dispatchAfterDelay:delay block:block];
}


@end
