//
//  ARC Helper
//
//  Version 2.1
//
//  Created by Nick Lockwood on 05/01/2012.
//  Copyright 2012 Charcoal Design
//
//  Distributed under the permissive zlib license
//  Get the latest version from here:
//
//  https://gist.github.com/1563325
//

#ifndef ah_retain
#if __has_feature(objc_arc)
#define ah_retain self
#define ah_dealloc self
#define release self
#define autorelease self
#else
#define ah_retain retain
#define ah_dealloc dealloc
#define __bridge
#endif
#endif

//  Weak reference support

#import <Availability.h>
#if (!__has_feature(objc_arc)) || \
(defined __IPHONE_OS_VERSION_MIN_REQUIRED && \
__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_5_0) || \
(defined __MAC_OS_X_VERSION_MIN_REQUIRED && \
__MAC_OS_X_VERSION_MIN_REQUIRED < __MAC_10_7)
#undef weak
#define weak unsafe_unretained
#undef __weak
#define __weak __unsafe_unretained
#endif

//  Weak delegate support

#ifndef ah_weak
#import <Availability.h>
#if (__has_feature(objc_arc)) && \
((defined __IPHONE_OS_VERSION_MIN_REQUIRED && \
__IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0) || \
(defined __MAC_OS_X_VERSION_MIN_REQUIRED && \
__MAC_OS_X_VERSION_MIN_REQUIRED > __MAC_10_7))
#define ah_weak weak
#define __ah_weak __weak
#else
#define ah_weak unsafe_unretained
#define __ah_weak __unsafe_unretained
#endif
#endif

//  ARC Helper ends
