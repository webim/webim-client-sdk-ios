//
//  NSObject+Block.h
//
//
//
//


#import <Foundation/Foundation.h>


#define CALL_BLOCK(block, ...) do { if ((block) != nil) (block)(__VA_ARGS__); } while (0)
#define CALL_BLOCK_MAINTH(block, ...) do { if ((block) != nil) { [NSObject dispatchSyncOnMainThreadBlock:^{ block(__VA_ARGS__); }]; } } while (0)


@interface NSObject (Block)

+ (void)dispatchSyncOnMainThreadBlock:(void (^)(void))block;
+ (void)dispatchAfterDelay:(NSTimeInterval)delay block:(void (^)(void))block;
+ (void)dispatchOnMainThreadAfterDelay:(NSTimeInterval)delay block:(void (^)(void))block;

- (void)dispatchSyncOnMainThreadBlock:(void (^)(void))block;
- (void)dispatchAfterDelay:(NSTimeInterval)delay block:(void (^)(void))block;

@end
