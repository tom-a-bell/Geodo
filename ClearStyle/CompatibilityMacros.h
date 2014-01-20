//
//  CompatibilityMacros.h
//  ClearStyle
//
//  Created by Tom Bell on 14/12/2013.
//  Copyright (c) 2013 Tom Bell. All rights reserved.
//

// Define macros to handle iOS version compatibility
#ifndef kCFCoreFoundationVersionNumber_iOS_6_0
#define kCFCoreFoundationVersionNumber_iOS_6_0 793.00
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_6_1
#define kCFCoreFoundationVersionNumber_iOS_6_1 793.00
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_7_0
#define kCFCoreFoundationVersionNumber_iOS_7_0 847.21
#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
#define IF_IOS7_OR_GREATER(...) \
if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_7_0) \
{ \
__VA_ARGS__ \
}
#else
#define IF_IOS7_OR_GREATER(...)
#endif

#define IF_PRE_IOS7(...) \
if (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_7_0) \
{ \
__VA_ARGS__ \
}
