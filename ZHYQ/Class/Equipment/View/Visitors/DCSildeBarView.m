//
//  SideBarView.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/18.
//  Copyright © 2017年 焦平. All rights reserved.s
//

#import "DCSildeBarView.h"

#import "DCFiltrateViewController.h"
#import "LogFilterViewController.h"
#import "FaceFilterViewController.h"
#import "MsgFilterViewController.h"
#import "ParkFilterViewController.h"
#import "AppointMentParkFilterViewController.h"

#define AnimatorDuration  0.25

@interface DCSildeBarView() <UIGestureRecognizerDelegate>

@property (nonatomic,strong) UIView *coverView;//遮罩

@property (nonatomic,strong) UIViewController *filterView;//筛选视图

@property (nonatomic,strong) DCFiltrateViewController *versionFilterView;//访客筛选视图
@property (nonatomic,strong) LogFilterViewController *logFilterView;//日志筛选视图
@property (nonatomic,strong) FaceFilterViewController *faceFilterView;//人脸志筛选视图
@property (nonatomic,strong) MsgFilterViewController *msgFilterViewController;//消息视图
@property (nonatomic,strong) ParkFilterViewController *parkFilterViewController;    // 停车记录筛选
@property (nonatomic,strong) AppointMentParkFilterViewController *aptParkFilterViewController;    // 预约筛选

@end

@implementation DCSildeBarView

#pragma mark - LazyLaod
- (UIView *)coverView{
    if (!_coverView) {
        _coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
        _coverView.backgroundColor = [UIColor blackColor];
        _coverView.alpha = 0.0;
    }
    return _coverView;
}

- (DCFiltrateViewController *)versionFilterView{
    if (!_filterView) {
        _versionFilterView = [[DCFiltrateViewController alloc]init];
        _versionFilterView.view.frame = CGRectMake(KScreenWidth, 0, KScreenWidth * 0.8, KScreenHeight);
    }
    return _versionFilterView;
}
- (LogFilterViewController *)logFilterView {
    if (!_logFilterView) {
        _logFilterView = [[UIStoryboard storyboardWithName:@"Personal" bundle:nil] instantiateViewControllerWithIdentifier:@"LogFilterViewController"];
        _logFilterView.view.frame = CGRectMake(KScreenWidth, 0, KScreenWidth * 0.8, KScreenHeight);
    }
    return _logFilterView;
}
- (FaceFilterViewController *)faceFilterView {
    if (!_faceFilterView) {
        _faceFilterView = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"FaceFilterViewController"];
        _faceFilterView.view.frame = CGRectMake(KScreenWidth, 0, KScreenWidth * 0.8, KScreenHeight);
    }
    return _faceFilterView;
}
- (MsgFilterViewController *)msgFilterViewController {
    if (!_msgFilterViewController) {
        _msgFilterViewController = [[UIStoryboard storyboardWithName:@"Personal" bundle:nil] instantiateViewControllerWithIdentifier:@"MsgFilterViewController"];
        _msgFilterViewController.view.frame = CGRectMake(KScreenWidth, 0, KScreenWidth * 0.8, KScreenHeight);
    }
    return _msgFilterViewController;
}
- (ParkFilterViewController *)parkFilterViewController {
    if (!_parkFilterViewController) {
        _parkFilterViewController = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"ParkFilterViewController"];
        _parkFilterViewController.view.frame = CGRectMake(KScreenWidth, 0, KScreenWidth * 0.8, KScreenHeight);
    }
    return _parkFilterViewController;
}
- (AppointMentParkFilterViewController *)aptParkFilterViewController {
    if (!_aptParkFilterViewController) {
        _aptParkFilterViewController = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"AppointMentParkFilterViewController"];
        _aptParkFilterViewController.view.frame = CGRectMake(KScreenWidth, 0, KScreenWidth * 0.8, KScreenHeight);
    }
    return _aptParkFilterViewController;
}

#pragma mark - Show
+(void)dc_showSildBarViewController:(FilterType)filterType {
    DCSildeBarView *obj = [[DCSildeBarView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight) withFilterType:filterType];
    [kAppWindow addSubview:obj];
}

#pragma mark - initialize
-(instancetype)initWithFrame:(CGRect)frame withFilterType:(FilterType)filterType{
    if (self = [super initWithFrame:frame]) {
        
        [self setUpBaseSetting:filterType];
    }
    return self;
}

#pragma mark - 初始化设置
- (void)setUpBaseSetting:(FilterType)filterType
{
    [self addSubViews:filterType];
    
    [self addGestureRecognizer];
}


#pragma mark - 添加SubViews
- (void)addSubViews:(FilterType)filterType{
    
    [self addSubview:self.coverView];
    
    WEAKSELF
    switch (filterType) {
        case VersionFilter:
        {
            _filterView = self.versionFilterView;
            [self addSubview:_filterView.view];
            self.versionFilterView.sureClickBlock = ^(NSArray *selectArray) { //在筛选情况下的确定回调
                [weakSelf tapEvent];
            };
            break;
        }
            
        case LogFilter:
        {
            _filterView = self.logFilterView;
            [self addSubview:_filterView.view];
            WEAKSELF
            self.logFilterView.sureClickBlock = ^(NSArray *selectArray) { //在筛选情况下的确定回调
                [weakSelf tapEvent];
            };
            break;
        }
        case FaceFilter:
        {
            _filterView = self.faceFilterView;
            [self addSubview:_filterView.view];
            WEAKSELF
            self.faceFilterView.sureClickBlock = ^(NSArray *selectArray) { //在筛选情况下的确定回调
                [weakSelf tapEvent];
            };
            break;
        }
        case MessageFilter:
        {
            _filterView = self.msgFilterViewController;
            [self addSubview:_filterView.view];
            WEAKSELF
            self.msgFilterViewController.sureClickBlock = ^(NSArray *selectArray) { //在筛选情况下的确定回调
                [weakSelf tapEvent];
            };
            break;
        }
        case ParkRecordFilter:
        {
            _filterView = self.parkFilterViewController;
            [self addSubview:_filterView.view];
            WEAKSELF
            self.parkFilterViewController.sureClickBlock = ^(NSArray *selectArray) { //在筛选情况下的确定回调
                [weakSelf tapEvent];
            };
            break;
        }
        case AppointMentParkFilter:
        {
            _filterView = self.aptParkFilterViewController;
            [self addSubview:_filterView.view];
            WEAKSELF
            self.aptParkFilterViewController.sureClickBlock = ^(NSArray *selectArray) { //在筛选情况下的确定回调
                [weakSelf tapEvent];
            };
            break;
        }
            
        default:
            break;
    }
    
    [UIView animateWithDuration:AnimatorDuration animations:^{
        weakSelf.coverView.alpha = 0.4;
        weakSelf.filterView.view.x = KScreenWidth * 0.2;
    }];

}


#pragma mark - 添加手势和监听
- (void)addGestureRecognizer
{
    //添加手势
//    UIPanGestureRecognizer *pan=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panEvent:)]; //滑动
//    pan.delegate = self;
//    [self addGestureRecognizer:pan];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(panEvent:)];
    [swipe setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self addGestureRecognizer:swipe];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapEvent)];
    [self.coverView addGestureRecognizer:tap]; //点击
    
    //添加“frame”监听
    [self.filterView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

#pragma mark - private Methods
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"frame"]) {
        CGRect new = [change[@"new"] CGRectValue];
        CGFloat x = new.origin.x;
        if (x < KScreenWidth) {
            self.coverView.alpha = 0.4 * (1-x / KScreenWidth) + 0.1;
        }else{
            self.coverView.alpha = 0.0;
        }
    }
}

#pragma mark - 滑动手势事件
- (void)panEvent:(UIPanGestureRecognizer *)recognizer{
    
    /*
    CGPoint translation = [recognizer translationInView:self];
    
    if(UIGestureRecognizerStateBegan == recognizer.state || UIGestureRecognizerStateChanged == recognizer.state){
        
        if (translation.x > 0 ) {//右滑
            self.filterView.view.x = KScreenWidth * 0.2 + translation.x;
        }else{//左滑
            
            if (self.filterView.view.x < KScreenWidth * 0.2) {
                self.filterView.view.x = self.filterView.view.x - translation.x;
            }else{
                self.filterView.view.x = KScreenWidth * 0.2;
            }
        }
    }else{
        
        [self tapEvent];
    }
     */
    
    [self tapEvent];
}
#pragma mark - 点击手势事件
- (void)tapEvent{
    
    WEAKSELF
    [UIView animateWithDuration:AnimatorDuration animations:^{
        weakSelf.coverView.alpha = 0.0;
        weakSelf.filterView.view.x = KScreenWidth;
    } completion:^(BOOL finished) {
        
        [weakSelf removeAllSubviews];
        [weakSelf removeFromSuperview];
    }];
}

#pragma mark - 移除SubViews
- (void)removeAllSubviews {
    
    if (self.subviews.count) {
        UIView* child = self.subviews.lastObject;
        [child removeFromSuperview];
    }
}


#pragma mark - 销毁
- (void)dealloc{
    //移除监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.filterView removeObserver:self forKeyPath:@"frame"];
}

@end
