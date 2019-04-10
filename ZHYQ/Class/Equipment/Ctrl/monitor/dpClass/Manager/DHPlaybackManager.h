//
//  DHPlaybackManager.h
//  DataAdapterExample_Example
//
//  Created by 32943 on 2018/2/9.
//  Copyright © 2018年 ly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSSRecordInfo.h"

@interface DHPlaybackManager : NSObject

+ (DHPlaybackManager *)sharedInstance;

+ (void)unSharedInstance;

/** 查询某个月份的录像掩码如果当前有录像number为1
 * query record bitmask in a month
 * @pararm channelid 通道id channelid
 * @pararm month 查询月份 month
 * @pararm source 录像来源 record source
 * @pararm error error
 * @return [1, 0, 1, 0, 0 ...] 类似的表示该月某天是否有录像
 */
-(NSArray<NSNumber*>*) queryRecordBitmask:(NSString*)channelid month:(NSDate*)month source:(RecordSource)source error:(NSError**)error;

/** 查询某个时间段的录像记录
 * query recordinfo at a time
 * @pararm channelid 通道id channelid
 * @pararm begin 查询开始时间 begin time
 * @pararm end 查询结束时间 end time
 * @pararm source 录像来源 record source
 * @pararm error error
 * @return 录像列表 recordinfo list
 */
-(NSArray<DSSRecordInfo*>*) queryRecord:(NSString*)channelid begin:(NSDate*)begin end:(NSDate*)end source:(RecordSource)source error:(NSError**)error;

@end
