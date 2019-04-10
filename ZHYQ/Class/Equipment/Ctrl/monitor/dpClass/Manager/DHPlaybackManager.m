//
//  DHPlaybackManager.m
//  DataAdapterExample_Example
//
//  Created by 32943 on 2018/2/9.
//  Copyright © 2018年 ly. All rights reserved.
//

#import "DHPlaybackManager.h"
#import "DSSPlatformDataAdapterRecord.h"
#import "DHDataCenter.h"

@interface DHPlaybackManager()
@property (nonatomic, strong) DSSPlatformDataAdapterRecord *recordAdapter;
@end

static DHPlaybackManager *g_playbackManager = nil;
@implementation DHPlaybackManager
+ (DHPlaybackManager *)sharedInstance
{
   
    if (!g_playbackManager) {
        g_playbackManager = [[self alloc] init];
    }
    return g_playbackManager;
}

+ (void)unSharedInstance {
    if (g_playbackManager) {
        g_playbackManager = nil;
    }
}

- (instancetype)init {
    self = [super init];
    if (self)
    {
        _recordAdapter = [[DSSPlatformDataAdapterRecord alloc] init];
//        _recordAdapter.core = [DHDataCenter sharedInstance].coreAdapter;
    }
    return self;
}

- (NSArray<NSNumber *> *)queryRecordBitmask:(NSString*)channelid month:(NSDate*)month source:(RecordSource)source error:(NSError**)error {
   return [_recordAdapter queryRecordBitmask:channelid month:month source:source error:error];
}

- (NSArray<DSSRecordInfo*>*)queryRecord:(NSString*)channelid begin:(NSDate*)begin end:(NSDate*)end source:(RecordSource)source error:(NSError**)error {
    return [_recordAdapter queryRecord:channelid begin:begin end:end source:source error:error];
}

@end
