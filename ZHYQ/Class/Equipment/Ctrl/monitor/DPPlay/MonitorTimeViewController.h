//
//  MonitorTimeViewController.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/1/9.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "RootViewController.h"

#import "DHPlaybackManager.h"
#import "DHLoginManager.h"
#import "DHDataCenter.h"
#import "PlaybackProgress.h"
#import "ZComBoxView.h"
#import "DHPlayWindow.h"
#import "DPSPBCamera.h"

@protocol SelTimeDelegate <NSObject>

- (void)selTime:(NSInteger)index withRange:(NSString *)timeRange withDSSRecordInfo:(DSSRecordInfo *)recordInfo;

@end

@interface MonitorTimeViewController : RootViewController

@property (nonatomic,assign) id<SelTimeDelegate> timeDelegate;
@property (nonatomic,copy) NSString *queryDate; // yyyy-MM-dd

@end
