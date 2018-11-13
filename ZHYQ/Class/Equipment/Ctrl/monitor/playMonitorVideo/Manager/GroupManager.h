//
//  GroupManager.h
//  DemoDPSDK
//
//  Created by jiang_bin on 14-4-16.
//  Copyright (c) 2014年 jiang_bin. All rights reserved.
//  查询设备分组信息

#import <Foundation/Foundation.h>
#import "DHDataCenter.h"
#import "PubDefine.h"

@interface GroupManager : NSObject
{
    
}

@property (assign,nonatomic) BOOL isLoadComplete;   /**< 是否加载完成 */
@property (assign,nonatomic) int  groupLen;         /**< 分组长度 */

+ (GroupManager *) sharedInstance;

/**
 *  向平台请求数据业务回调
 *  @return 返回错误码见dpsdk_retval_e
 */
- (int)attachIssueCallback;

/**
 *  加载组织设备信息.
 *  @return 返回错误码见dpsdk_retval_e
 */
- (int)loadGroupInfo;

/**
 *  解析通道信息
 */
- (void)parseChannelInfo;

+ (NSInteger)Platform_GetDeviceType:(NSString *)deviceID;


@end
