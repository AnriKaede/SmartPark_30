//
//  PubDefine.h
//  DHView
//
//  Created by nobuts on 13-6-13.
//  Copyright (c) 2013年 nobuts. All rights reserved.
//

#ifndef DHView_PubDefine_h
#define DHView_PubDefine_h


#ifndef SYNTHESIZE_SINGLETON_FOR_CLASS

#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#pragma mark -
#pragma mark Singleton

/* Synthesize Singleton For Class
 *
 * Creates a singleton interface for the specified class with the following methods:
 *
 * + (MyClass*) sharedInstance;
 * + (void) purgeSharedInstance;
 *
 * Calling sharedInstance will instantiate the class and swizzle some methods to ensure
 * that only a single instance ever exists.
 * Calling purgeSharedInstance will destroy the shared instance and return the swizzled
 * methods to their former selves.
 *
 *
 * Usage:
 *
 * MyClass.h:
 * ========================================
 *    #import "SynthesizeSingleton.h"
 *
 *    @interface MyClass: SomeSuperclass
 *    {
 *        ...
 *    }
 *    SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(MyClass);
 *
 *    @end
 * ========================================
 *
 *
 *    MyClass.m:
 * ========================================
 *    #import "MyClass.h"
 *
 *    @implementation MyClass
 *
 *    SYNTHESIZE_SINGLETON_FOR_CLASS(MyClass);
 *
 *    ...
 *
 *    @end
 * ========================================
 *
 *
 * Note: Calling alloc manually will also initialize the singleton, so you
 * can call a more complex init routine to initialize the singleton like so:
 *
 * [[MyClass alloc] initWithParam:firstParam secondParam:secondParam];
 *
 * Just be sure to make such a call BEFORE you call "sharedInstance" in
 * your program.
 */

#define SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(__CLASSNAME__)    \
\
+ (__CLASSNAME__*) sharedInstance;    \
+ (void) purgeSharedInstance;


#define SYNTHESIZE_SINGLETON_FOR_CLASS(__CLASSNAME__)    \
\
static __CLASSNAME__* volatile _##__CLASSNAME__##_sharedInstance = nil;    \
\
+ (__CLASSNAME__*) sharedInstanceNoSynch    \
{    \
return (__CLASSNAME__*) _##__CLASSNAME__##_sharedInstance;    \
}    \
\
+ (__CLASSNAME__*) sharedInstanceSynch    \
{    \
@synchronized(self)    \
{    \
if(nil == _##__CLASSNAME__##_sharedInstance)    \
{    \
_##__CLASSNAME__##_sharedInstance = [[self alloc] init];    \
}    \
else    \
{    \
NSAssert2(1==0, @"SynthesizeSingleton: %@ ERROR: +(%@ *)sharedInstance method did not get swizzled.", self, self);    \
}    \
}    \
return (__CLASSNAME__*) _##__CLASSNAME__##_sharedInstance;    \
}    \
\
+ (__CLASSNAME__*) sharedInstance    \
{    \
return [self sharedInstanceSynch]; \
}    \
\
+ (id)allocWithZone:(NSZone*) zone    \
{    \
@synchronized(self)    \
{    \
if (nil == _##__CLASSNAME__##_sharedInstance)    \
{    \
_##__CLASSNAME__##_sharedInstance = [super allocWithZone:zone];    \
if(nil != _##__CLASSNAME__##_sharedInstance)    \
{    \
Method newSharedInstanceMethod = class_getClassMethod(self, @selector(sharedInstanceNoSynch));    \
method_setImplementation(class_getClassMethod(self, @selector(sharedInstance)), method_getImplementation(newSharedInstanceMethod));    \
method_setImplementation(class_getInstanceMethod(self, @selector(retainCount)), class_getMethodImplementation(self, @selector(retainCountDoNothing)));    \
method_setImplementation(class_getInstanceMethod(self, @selector(release)), class_getMethodImplementation(self, @selector(releaseDoNothing)));    \
method_setImplementation(class_getInstanceMethod(self, @selector(autorelease)), class_getMethodImplementation(self, @selector(autoreleaseDoNothing)));    \
}    \
}    \
}    \
return _##__CLASSNAME__##_sharedInstance;    \
}    \
\
+ (void)purgeSharedInstance    \
{    \
@synchronized(self)    \
{    \
if(nil != _##__CLASSNAME__##_sharedInstance)    \
{    \
Method newSharedInstanceMethod = class_getClassMethod(self, @selector(sharedInstanceSynch));    \
method_setImplementation(class_getClassMethod(self, @selector(sharedInstance)), method_getImplementation(newSharedInstanceMethod));    \
method_setImplementation(class_getInstanceMethod(self, @selector(retainCount)), class_getMethodImplementation(self, @selector(retainCountDoSomething)));    \
method_setImplementation(class_getInstanceMethod(self, @selector(release)), class_getMethodImplementation(self, @selector(releaseDoSomething)));    \
method_setImplementation(class_getInstanceMethod(self, @selector(autorelease)), class_getMethodImplementation(self, @selector(autoreleaseDoSomething)));    \
[_##__CLASSNAME__##_sharedInstance release];    \
_##__CLASSNAME__##_sharedInstance = nil;    \
}    \
}    \
}    \
\
- (id)copyWithZone:(NSZone *)zone    \
{    \
return self;    \
}    \
\
- (id)retain    \
{    \
return self;    \
}    \
\
- (NSUInteger)retainCount    \
{    \
NSAssert1(1==0, @"SynthesizeSingleton: %@ ERROR: -(NSUInteger)retainCount method did not get swizzled.", self);    \
return NSUIntegerMax;    \
}    \
\
- (NSUInteger)retainCountDoNothing    \
{    \
return NSUIntegerMax;    \
}    \
- (NSUInteger)retainCountDoSomething    \
{    \
return [super retainCount];    \
}    \
\
- (oneway void)release    \
{    \
NSAssert1(1==0, @"SynthesizeSingleton: %@ ERROR: -(void)release method did not get swizzled.", self);    \
}    \
\
- (void)releaseDoNothing{}    \
\
- (void)releaseDoSomething    \
{    \
@synchronized(self)    \
{    \
[super release];    \
}    \
}    \
\
- (id)autorelease    \
{    \
NSAssert1(1==0, @"SynthesizeSingleton: %@ ERROR: -(id)autorelease method did not get swizzled.", self);    \
return self;    \
}    \
\
- (id)autoreleaseDoNothing    \
{    \
return self;    \
}    \
\
- (id)autoreleaseDoSomething    \
{    \
return [super autorelease];    \
}

#endif

#define MSG(title,msg,ok)  if(msg != nil && [msg length]>0) {\
[[DHHudPrecess sharedInstance] ShowTips:msg delayTime:1.5  atView:nil];}\


#define LEGALCHAR "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ@_."


#define SHOULD_INPUT_CHAR {char cExcluded[] = LEGALCHAR ; \
const char* replace = [string cStringUsingEncoding:NSUTF8StringEncoding];\
if (replace != NULL)\
{\
for (int i=0 ; i < strlen(cExcluded) ; i++)\
{\
if (NULL != strchr(replace, cExcluded[i]))\
{\
return YES;\
}\
}\
return NO;\
}}

#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen] bounds].size.height-(double)568 ) < DBL_EPSILON ) 

//Add by jiang_bin
#define _L(str) NSLocalizedString(str,nil)
#define Sleep(x) usleep(x*1000)
#define Release(obj) {if(obj){[obj release];obj=nil;}}

//指针删除
#define SAFE_DELETE(ptr) \
if(ptr)\
{\
delete ptr; \
ptr = NULL; \
}

#define SAFE_DELETE_ARRAY(ptr) \
if(ptr) \
{ \
delete []ptr; \
ptr = NULL; \
}

#define KEYWINDOW [[UIApplication sharedApplication]keyWindow]
//SDK 权限
#define UNLLONG unsigned long long
#define DSL_RIGHT_ALL           0xFFFFFFFF              //所有权限
#define DSL_RIGHT_MONITOR       0x00000001              // 实时监视
#define DSL_RIGHT_PLAYBACK      0x00000002              // 录像回放
#define DSL_RIGHT_PLAY          (DSL_RIGHT_MONITOR|DSL_RIGHT_PLAYBACK)    //播放权限
#define DSL_RIGHT_PTZ           0x00000008              // 云台
#define DSL_RIGHT_TALK          0x00004000              // 对讲
//颜色定义
#define COLOR_BACKGROUND           [UIColor colorWithRed:165.0/255.0 green:185.0/255.0 blue:208.0/255 alpha:1]
#define COLOR_CELL                 [UIColor colorWithRed:134/255.0 green:154/255.0 blue:178/255.0 alpha:1]
#define COLOR_DARKBLUE             [UIColor colorWithRed:47.0/255 green:63.0/255 blue:81.0/255 alpha:1]
#define COLOR_OPAQUE               [UIColor colorWithRed:125.0/255 green:0/255 blue:255.0/255 alpha:0.2]
#define COLOR_WHITE_CUSTOM(ALPHA)  [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:ALPHA]
#define COLOR_BLACK_CUSTOM(ALPHA)  [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:ALPHA]
#define COLOR_DARK                 [UIColor colorWithRed:52/255.0 green:59/255.0 blue:70/255.0 alpha:1.00f]
#define COLOR_CELL_SELECTED        [UIColor colorWithRed:58/255.0 green:110/255.0 blue:165/255.0 alpha:1.00f]

//通过比例因子缩放矩形
CG_INLINE CGRect
DHRectMakeByProportion(CGFloat x, CGFloat y, CGFloat width, CGFloat height, CGFloat proportion)
{
    CGRect rect;
    rect.origin.x = x*proportion;
    rect.origin.y = y*proportion;
    rect.size.width = width*proportion;
    rect.size.height = height*proportion;
    return rect;
}

/**
 *  int型转换为NSString
 *  @param intNumber
 *  @return NSString类型
 */
inline NSString*
DHStringMakeByInt(int intNumber)
{
    return [NSString stringWithFormat:@"%d", intNumber];
}

#endif
