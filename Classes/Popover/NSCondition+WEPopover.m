//
// Created by Werner Altewischer on 25/04/2017.
// Copyright (c) 2017 Werner IT Consultancy. All rights reserved.
//

#import "NSCondition+WEPopover.h"

@implementation NSCondition (WEPopover)

- (BOOL)weWaitForPredicate:(BOOL (^)(void))predicate completion:(void (^)(BOOL waited))completion {
    return [self weWaitForPredicate:predicate timeout:0.0 completion:^(BOOL predicateResult, BOOL waited) {
        if (completion) {
            completion(waited);
        }
    }];
}

- (BOOL)weWaitForPredicate:(BOOL (^)(void))predicate timeout:(NSTimeInterval)timeout completion:(void (^)(BOOL predicateResult, BOOL waited))completion {
    return [self weWaitForPredicate:predicate timeout:timeout completion:completion timeoutOccured:NO waited:NO];
}

- (BOOL)weWaitForPredicate:(BOOL (^)(void))predicate timeout:(NSTimeInterval)timeout completion:(void (^)(BOOL predicateEvaluation, BOOL waited))completion timeoutOccured:(BOOL)timeoutOccured waited:(BOOL)waited {

    BOOL predicateResult = NO;

    [self lock];
    predicateResult = predicate();
    [self unlock];

    if (predicateResult || timeoutOccured) {
        if (completion) {
            completion(predicateResult, waited);
        }
        return NO;
    } else {

        NSDate *expirationDate = nil;
        if (timeout > 0.0) {
            expirationDate = [NSDate dateWithTimeIntervalSinceNow:timeout];
        }

        id __weak weakSelf = self;

        [self wePerformBlockInBackground:^id {
            BOOL predicateResult1 = NO;
            [weakSelf lock];
            while (weakSelf != nil && (predicateResult1 = predicate()) == NO && (expirationDate == nil || [expirationDate timeIntervalSinceNow] > 0.0)) {
                if (expirationDate == nil) {
                    //Wait for max 1 second to be able to check again if weakSelf != nil (object could be deallocated).
                    [weakSelf waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
                } else {
                    [weakSelf waitUntilDate:expirationDate];
                }
            }
            [weakSelf unlock];
            return @(predicateResult1);
        }                 withCompletion:^(id resultFromBlock) {
            BOOL timeoutOccured1 = ![resultFromBlock boolValue];
            [weakSelf weWaitForPredicate:predicate timeout:timeout completion:completion timeoutOccured:timeoutOccured1 waited:YES];
        }];
        return YES;
    }
}

/**
 Performs a thread safe predicate modification while broadcasting the condition which is paired to it.
 */
- (void)weBroadcastForPredicateModification:(void (^)(void))modification {
    [self lock];
    modification();
    [self broadcast];
    [self unlock];
}

- (void)wePerformBlock:(id (^)(void))block onQueue:(dispatch_queue_t)queue withCompletion:(void (^)(id resultFromBlock))completion {
    if (block) {
        dispatch_async(queue, ^{
            id result = block();
            if (completion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(result);
                });
            }
        });
    }
}

- (void)wePerformBlockInBackground:(id (^)(void))block withCompletion:(void (^)(id resultFromBlock))completion  {
    [self wePerformBlock:block onQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) withCompletion:completion];
}

@end