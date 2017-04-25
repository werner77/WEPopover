//
// Created by Werner Altewischer on 25/04/2017.
// Copyright (c) 2017 Werner IT Consultancy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCondition (WEPopover)

/**
 Waits in a background thread until the specified condition is broadcast/signalled and the specified predicate is true using appropriate thread safe locking techniques.

 Using this method is assured that the wait stops when this object (self) is deallocated

 Returns NO iff the predicate returned true without having to wait, YES if the wait actually had to occur.

 @see broadcastCondition:forPredicateModification:
 */
- (BOOL)weWaitForPredicate:(BOOL (^)(void))predicate completion:(void (^)(BOOL waited))completion;

/**
 Waits with a timeout, specify timeout <= 0.0 to wait indefinitely.

 The completion block has a BOOL argument predicateResult which is true if the predicate evaluated to true within the timeout period and false otherwise.

 Returns NO iff the predicate returned true without having to wait, YES if the wait actually had to occur.
 */
- (BOOL)weWaitForPredicate:(BOOL (^)(void))predicate timeout:(NSTimeInterval)timeout completion:(void (^)(BOOL predicateResult, BOOL waited))completion;

/**
 Performs a thread safe predicate modification while broadcasting the condition which is paired to it.
 */
- (void)weBroadcastForPredicateModification:(void (^)(void))modification;

@end