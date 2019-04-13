//
//  MealIntimeCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/2/1.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "MealIntimeCell.h"
#import "AAChartView.h"

#import "DHPlayWindow.h"
#import "DPSRTCamera.h"
#import "DHLoginManager.h"
#import "DHDataCenter.h"
#import "DHStreamSelectView.h"
#import "DHHudPrecess.h"

@interface MealIntimeCell()
@property (nonatomic, strong) AAChartModel *mixChartModel;
@property (nonatomic, strong) AAChartView  *mixChartView;
@end

@implementation MealIntimeCell
{
    __weak IBOutlet UIView *_topCountView;
    
    __weak IBOutlet UIView *_bottomView;
    __weak IBOutlet NSLayoutConstraint *_playHeight;
    
    DHPlayWindow *_playWindow;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self _initView];
}

- (void)_initView {
    // 添加渐变色
    [NavGradient viewAddGradient:_topCountView];
    // 头部日期背景
    UIView *filterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 40)];
//    filterView.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
    [_topCountView addSubview:filterView];
    
    UILabel *elcLabel = [[UILabel alloc] init];
    elcLabel.frame = CGRectMake(10,13,40,17);
    elcLabel.text = @"人数";
    elcLabel.textColor = [UIColor colorWithRed:255/255 green:255/255 blue:255/255 alpha:1];
    [filterView addSubview:elcLabel];
    
    UIView *elcView = [[UIView alloc] init];
    elcView.frame = CGRectMake(elcLabel.right + 7,18,25,7.5);
    elcView.backgroundColor = [UIColor colorWithHexString:@"#FFC921"];
    [filterView addSubview:elcView];
    
    UILabel *parkSnapLabel = [[UILabel alloc] init];
    parkSnapLabel.frame = CGRectMake(elcView.right + 18,elcLabel.top,60,17);
    parkSnapLabel.text = @"消费额";
    parkSnapLabel.textColor = [UIColor whiteColor];
    [filterView addSubview:parkSnapLabel];
    
    UIView *parkSnapLineView = [[UIView alloc] init];
    parkSnapLineView.frame = CGRectMake(parkSnapLabel.right + 9,18,25,7.5);
    parkSnapLineView.backgroundColor = [UIColor colorWithHexString:@"#00FF3C"];
    [filterView addSubview:parkSnapLineView];
    
    // 图表
    [self _initChartView];
    
    // 视频监控视图
    [self _initPlayView];
    
    NSString *channelId = @"1000229$1$0$0";
    [MonitorLogin selectNodeWithChanneId:channelId withNode:^(TreeNode *node) {
        if(node != nil){
            DSSChannelInfo *info = (DSSChannelInfo *)node.content;
            if(info.isOnline){
                [self startToplay:channelId winIndex:0 streamType:0];
            }else {
                [[self viewController] showHint:@"设备离线"];
            }
        }else {
            [[self viewController] showHint:@"未找到此设备"];
        }
    }];
}

- (void)_initChartView {
    self.mixChartView = [[AAChartView alloc] initWithFrame:CGRectMake(0, 40, KScreenWidth, 275)];
    self.mixChartView.contentHeight = 255;
    self.mixChartView.isClearBackgroundColor = YES;
    self.mixChartView.backgroundColor = [UIColor clearColor];
    self.mixChartView.clipsToBounds = YES;
    
    self.mixChartModel= AAObject(AAChartModel)
    .chartTypeSet(AAChartTypeColumn)
    .titleSet(@"")
    .subtitleSet(@"")
    .categoriesSet(@[])
    .yAxisTitleSet(@"")
    .xAxisLabelsFontColorSet(@"#ffffff")    // x轴坐标值颜色
    .yAxisLabelsFontColorSet(@"#ffffff")    // y轴坐标值颜色
    .seriesSet(@[
                 AAObject(AASeriesElement)
                 .nameSet(@"人数")
                 .dataSet(@[]),
                 
                 AAObject(AASeriesElement)
                 .nameSet(@"消费额")
                 .dataSet(@[]),
                 ]
               )
    ;
    
    self.mixChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.mixChartModel.symbol = AAChartSymbolTypeCircle;
    self.mixChartModel.colorsTheme = @[@"#FFC921", @"#00FF3C"];
    [self.mixChartView aa_drawChartWithChartModel:_mixChartModel];
    
    [_topCountView addSubview:_mixChartView];
}

#pragma mark 就餐热度 实时视频
- (void)_initPlayView {
    _playWindow = [[DHPlayWindow alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth - 24, _playHeight.constant*wScale)];
    [_playWindow defultwindows:1];
    DSSUserInfo* userinfo = [DHLoginManager sharedInstance].userInfo;
    NSString *host = [[DHDataCenter sharedInstance] getHost];
    int port = [[DHDataCenter sharedInstance] getPort];
    [_playWindow setHost:host Port:port UserName:userinfo.userName];
    _playWindow.hideDefultToolViews = YES;
    [_bottomView addSubview:_playWindow];
}

#pragma mark 设置数据
- (void)setCostData:(NSArray *)costData {
    _costData = costData;
    
    [self refreshChart];
}

#pragma mark 刷新统计图表
- (void)refreshChart {
    
    self.mixChartView = nil;
    [_mixChartView removeFromSuperview];
    
    self.mixChartView = [[AAChartView alloc]initWithFrame:CGRectMake(0, 40, KScreenWidth, 275)];
    self.mixChartView.contentHeight = 255;
    self.mixChartView.userInteractionEnabled = YES;
    self.mixChartView.isClearBackgroundColor = YES;
    self.mixChartView.backgroundColor = [UIColor clearColor];
    [_topCountView addSubview:self.mixChartView];
    
    self.mixChartModel= AAObject(AAChartModel)
    .chartTypeSet(AAChartTypeColumn)
    .titleSet(@"")
    .subtitleSet(@"")
    .categoriesSet(_xRollerData)
    .yAxisTitleSet(@"")
    .xAxisLabelsFontColorSet(@"#ffffff")    // x轴坐标值颜色
    .yAxisLabelsFontColorSet(@"#ffffff")    // y轴坐标值颜色
    .seriesSet(@[
                 AAObject(AASeriesElement)
                 .nameSet(@"人数")
                 .dataSet(_numData),
                 
                 AAObject(AASeriesElement)
                 .nameSet(@"消费额")
                 .dataSet(_costData),
                 ]
               )
    ;
    
    self.mixChartModel.symbolStyle = AAChartSymbolStyleTypeDefault;
    self.mixChartModel.symbol = AAChartSymbolTypeCircle;
    self.mixChartModel.colorsTheme = @[@"#FFC921", @"#00FF3C"];
    [self.mixChartView aa_drawChartWithChartModel:_mixChartModel];
}

#pragma mark 新版大华SDK播放
- (void)startToplay:(NSString *)local_channelId winIndex:(int)winIndex streamType:(int)streamType{
    DSSUserInfo* userinfo = [DHLoginManager sharedInstance].userInfo;
    NSNumber* handleDPSDKEntity = (NSNumber*)[userinfo getInfoValueForKey:kUserInfoHandleDPSDKEntity];
    //  NSString* handleRestToken = [[DHDataCenter sharedInstance] getLoginToken];
    DPSRTCamera* ymCamera = [[DPSRTCamera alloc] init];
    ymCamera.dpHandle = [handleDPSDKEntity longValue];
    ymCamera.cameraID = local_channelId;
    //  ymCamera.dpRestToken = handleRestToken;
    ymCamera.server_ip = [[DHDataCenter sharedInstance] getHost];
    ymCamera.server_port = [[DHDataCenter sharedInstance] getPort];
    ymCamera.isCheckPermission = YES;
    ymCamera.mediaType = 1;
    //如果支持三码流，就默认播放辅码流，只有在用户主动选择三码流时才会去播放三码流
    //default stream ：subStream
    DSSChannelInfo* channelInfo = (DSSChannelInfo *)[DHDataCenter sharedInstance].selectNode.content;
    DSSDeviceInfo *deviceInfo = [[DHDeviceManager sharedInstance] getDeviceInfo:[channelInfo deviceId]];
    if ([self isThirdStreamSupported:local_channelId]) {
        ymCamera.streamType = 2;
    } else {
        if ([self isSubStreamSupported:local_channelId]) {
            ymCamera.streamType = 2;
        } else {
            ymCamera.streamType = 1;
        }
    }
    [_playWindow playCamera:ymCamera withName:channelInfo.name at:winIndex deviceProvide:deviceInfo.deviceProvide];
    
}
- (BOOL)isThirdStreamSupported:(NSString *)channelIDStr{
    if (channelIDStr != nil || ![channelIDStr isEqualToString:@""]) {
        DSSChannelInfo* channelInfo = (DSSChannelInfo *)[DHDataCenter sharedInstance].selectNode.content;
        if(channelInfo.encChannelInfo.streamtypeSupported == 3){
            return YES;
        }
        return NO;
    }
    return NO;
}
- (BOOL)isSubStreamSupported:(NSString *)channelIDStr{
    if (channelIDStr != nil || ![channelIDStr isEqualToString:@""]) {
        DSSChannelInfo* channelInfo = (DSSChannelInfo *)[DHDataCenter sharedInstance].selectNode.content;
        if(channelInfo.encChannelInfo.streamtypeSupported == 2){
            return YES;
        }
        return NO;
    }
    return NO;
}

- (void)stopWinPlay {
    [_playWindow stopAll];
}

@end
