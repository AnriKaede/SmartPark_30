//
//  MealIntimeCell.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/2/1.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "MealIntimeCell.h"
#import "AAChartView.h"

#import "DHVideoWnd.h"
#import "PreviewManager.h"
#import "TalkManager.h"

@interface MealIntimeCell()
@property (nonatomic, strong) AAChartModel *mixChartModel;
@property (nonatomic, strong) AAChartView  *mixChartView;
@end

@implementation MealIntimeCell
{
    __weak IBOutlet UIView *_topCountView;
    
    __weak IBOutlet UIView *_bottomView;
    __weak IBOutlet NSLayoutConstraint *_playHeight;
    
    DHVideoWnd  *videoWnd_;
    UIButton *_colseBt;
    BOOL _isHidBar;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self _initView];
    
    [self addNotification];
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
    
    [DHDataCenter sharedInstance].channelID = @"1000229$1$0$0"; // 二楼 1000235$1$0$0
    [[PreviewManager sharedInstance] initData];
    int flag = [[PreviewManager sharedInstance]openRealPlay:(__bridge void *)(videoWnd_)];
    NSLog(@"%d", flag);
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
    // 创建视频播放视图
    videoWnd_ = [[DHVideoWnd alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth - 24, _playHeight.constant*wScale)];
    videoWnd_.backgroundColor = [UIColor orangeColor];
    [_bottomView addSubview:videoWnd_];
    
    /*
    UITapGestureRecognizer *fullTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fullAction)];
    fullTap.numberOfTapsRequired = 2;
    [videoWnd_ addGestureRecognizer:fullTap];
    
    _colseBt = [UIButton buttonWithType:UIButtonTypeCustom];
    _colseBt.hidden = YES;
    _colseBt.frame = CGRectMake(KScreenWidth - 80, KScreenHeight - 60, 50, 50);
    if(KScreenWidth > 440){ // ipad
        _colseBt.frame = CGRectMake(KScreenWidth - 80, KScreenHeight - 60 - 44, 50, 50);
    }else {
        _colseBt.frame = CGRectMake(KScreenWidth - 80, KScreenHeight - 60, 50, 50);
    }
    [_colseBt setBackgroundImage:[UIImage imageNamed:@"show_menu_close"] forState:UIControlStateNormal];
    [_colseBt addTarget:self action:@selector(closeFull) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_colseBt];
     */
}

// 全屏显示
- (void)fullAction {
    _colseBt.hidden = NO;
    videoWnd_.userInteractionEnabled = NO;
    
    // 改变视频frame
    videoWnd_.transform = CGAffineTransformRotate(videoWnd_.transform, M_PI_2);
    if(KScreenWidth > 440){ // ipad
        videoWnd_.frame = CGRectMake(KScreenWidth, -44, -KScreenWidth, KScreenHeight);
    }else {
        videoWnd_.frame = CGRectMake(KScreenWidth, 0, -KScreenWidth, KScreenHeight);
    }
}
- (void)closeFull {
    _isHidBar = NO;
    _colseBt.hidden = YES;
    videoWnd_.userInteractionEnabled = YES;
    
    videoWnd_.transform = CGAffineTransformRotate(videoWnd_.transform, -M_PI_2);
    videoWnd_.frame = CGRectMake(0, 0, KScreenWidth, _bottomView.height);
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

#pragma mark - 视频播放Notification process
-(void)addNotification
{
    NSNotificationCenter *notfiyCenter = [NSNotificationCenter defaultCenter];
    
    [notfiyCenter addObserver:self selector:@selector(appHasGoneInForegroundNotification) name:UIApplicationDidBecomeActiveNotification object:nil];
    [notfiyCenter addObserver:self selector:@selector(appEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];
}
-(void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)appHasGoneInForegroundNotification
{
    //重新进入前台的时候 app重新打开之前后台关闭的视频
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[PreviewManager sharedInstance]openRealPlay:(__bridge void *)(videoWnd_)];
    });
    NSLog(@"appHasGoneInForegroundNotification--openRealPlay");
}
-(void)appEnterBackgroundNotification
{
    //进入后台之后
    //如果当前打开视频的话 需要默认关闭
    [[PreviewManager sharedInstance]stopRealPlay];
    [[TalkManager sharedInstance]stopTalk];
}

-(void)dealloc
{
    [self removeNotification];
}

@end
