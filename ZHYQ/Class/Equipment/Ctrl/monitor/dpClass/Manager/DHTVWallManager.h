//
//  DHTVWallManager.h
//  DataAdapterExample_Example
//
//  Created by caidong on 2018/6/30.
//  Copyright © 2018年 ly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TVWallInfo.h"

@interface DHTVWallManager : NSObject
+ (instancetype)sharedInstance;

+ (void)unSharedInstance;

/**
 获取电视墙列表
 @param error 错误
 @return NSArray<TVWallInfo>
 */
- (NSArray<TVWallInfo *> *)getTVWallList:(NSError **)error;

/**
 获取电视墙的任务列表
 @param tvWallId 电视墙Id
 @param error 错误
 @return NSArray<TVWallTaskBaseInfo>
 */
- (NSArray<TVWallTaskBaseInfo *> *)getTVWallTaskList:(NSInteger)tvWallId error:(NSError **)error;

/**
 任务上墙
 @param tvWallInfo 电视墙信息
 @param taskId 任务Id
 @param error 错误
 @return BOOL
 */
- (BOOL)taskMapToWallWithTVWallInfo:(TVWallInfo *)tvWallInfo taskId:(NSInteger)taskId error:(NSError **)error ;
@end
