//
//  MonitorCenterViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/11.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "MonitorCenterViewController.h"

#import "InDoorMonitorViewController.h"
#import "OutDoorMonitorViewController.h"
#import "TopMenuModel.h"

@interface MonitorCenterViewController ()<SGPageTitleViewDelegate,YQPageContentScrollViewDelegate>
{
    NSString *notificationName;
    UIButton *rightBtn;
    
    NSMutableArray *_statusArr;
}

@property (nonatomic,strong) NSMutableArray *titleDataArr;

@property (nonatomic,strong) NSMutableArray *titleArr;

@property (nonatomic, strong) YQSegmentView *pageTitleView;
@property (nonatomic, strong) YQPageContentScrollView *pageContentScrollView;

@end

@implementation MonitorCenterViewController

-(NSMutableArray *)titleDataArr
{
    if (_titleDataArr == nil) {
        _titleDataArr = [NSMutableArray array];
    }
    return _titleDataArr;
}

-(NSMutableArray *)titleArr
{
    if (_titleArr == nil) {
        _titleArr = [NSMutableArray array];
    }
    return _titleArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _statusArr = @[@"0",@"0",@"0",@"0"].mutableCopy;
    
    self.view.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:225.0/255.0 blue:215.0/255.0 alpha:1];
    
    [self _loadTitleData];
    
    [self initNavItems];
    
    [kNotificationCenter addObserver:self selector:@selector(changeBtnImage:) name:@"changeBtnImageNotification" object:nil];
    [kNotificationCenter addObserver:self selector:@selector(changeBtnImageToMap:) name:@"monitorchangeMapBtnImageNotification" object:nil];
    [kNotificationCenter addObserver:self selector:@selector(changeBtnImageToSlider:) name:@"monitorchangeSliderBtnImageNotification" object:nil];
    
}

-(void)_loadTitleData
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/public/getTopBulidingList?areaId=1",Main_Url];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSArray *arr = responseObject[@"responseData"];
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                TopMenuModel *model = [[TopMenuModel alloc] initWithDataDic:obj];
                [self.titleDataArr addObject:model];
                [self.titleArr addObject:model.BUILDING_NAME];
            }];
            [self _initTitleView];
        }
    } failure:^(NSError *error) {
        
    }];
}

-(void)_initTitleView
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    YQSegmentConfigure *configure = [YQSegmentConfigure pageTitleViewConfigure];
    configure.titleColor = [UIColor colorWithHexString:@"a8c7e9"];
    configure.titleSelectedColor = [UIColor whiteColor];
    configure.indicatorColor = [UIColor colorWithHexString:@"1B82D1"];
    configure.indicatorStyle = SGIndicatorStyleCover;
    
    /// pageTitleView
    self.pageTitleView = [YQSegmentView pageTitleViewWithFrame:CGRectMake(0, 0, self.view.frame.size.width-120*wScale, 44) delegate:self titleNames:self.titleArr configure:configure];
    self.navigationItem.titleView = _pageTitleView;
    _pageTitleView.backgroundColor = [UIColor clearColor];
    _pageTitleView.isTitleGradientEffect = YES;
    _pageTitleView.isNeedBounces = NO;
    _pageTitleView.isOpenTitleTextZoom = YES;
    _pageTitleView.isShowIndicator = NO;
    _pageTitleView.isShowBottomSeparator = NO;
    NSMutableArray *childVCs = [[NSMutableArray alloc]init];
    
    [self.titleDataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TopMenuModel *model = (TopMenuModel *)obj;
        if([model.IS_OUT isEqualToString:@"1"])
        {
            OutDoorMonitorViewController *outDoorVC = [[OutDoorMonitorViewController alloc] init];
            outDoorVC.title = model.BUILDING_NAME;
            [childVCs addObject:outDoorVC];
        }else{
            InDoorMonitorViewController *inDoorVC = [[InDoorMonitorViewController alloc] init];
            inDoorVC.title = model.BUILDING_NAME;
//            inDoorVC.buildID = model.BUILDING_ID;
//            inDoorVC.menuID = self.menuID;
//            inDoorVC.index = idx;
            [childVCs addObject:inDoorVC];
        }
    }];
    
    /// pageContentView
    self.pageContentScrollView = [[YQPageContentScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, KScreenHeight-64) parentVC:self childVCs:childVCs];
    _pageContentScrollView.delegatePageContentScrollView = self;
    [self.view addSubview:_pageContentScrollView];
}

-(void)initNavItems
{
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    rightBtn = [[UIButton alloc] init];
    rightBtn.frame = CGRectMake(0, 0, 40, 40);
    [rightBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    [rightBtn setImage:[UIImage imageNamed:@"switchmap"] forState:UIControlStateNormal];
//    [rightBtn setImage:[UIImage imageNamed:@"slideMenu"] forState:UIControlStateSelected];
    [rightBtn addTarget:self action:@selector(_rightBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    rightBtn.selected = NO;
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
}

-(void)_leftBarBtnItemClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)_rightBarBtnItemClick:(id)sender
{
    [kNotificationCenter postNotificationName:notificationName object:nil];
    
    UIButton *btn = (UIButton *)sender;
    switch (btn.tag) {
        case 100:
            {
                NSString *status = _statusArr[btn.tag-100];
                if ([status isEqualToString:@"0"]) {
                    [btn setImage:[UIImage imageNamed:@"slideMenu"] forState:UIControlStateNormal];
                    [_statusArr replaceObjectAtIndex:0 withObject:@"1"];
                }else{
                    [btn setImage:[UIImage imageNamed:@"switchmap"] forState:UIControlStateNormal];
                    [_statusArr replaceObjectAtIndex:0 withObject:@"0"];
                }
            }
            break;
        case 101:
            {
                NSString *status = _statusArr[btn.tag-100];
                if ([status isEqualToString:@"0"]) {
                    [btn setImage:[UIImage imageNamed:@"slideMenu"] forState:UIControlStateNormal];
                    [_statusArr replaceObjectAtIndex:1 withObject:@"1"];
                }else{
                    [btn setImage:[UIImage imageNamed:@"switchmap"] forState:UIControlStateNormal];
                    [_statusArr replaceObjectAtIndex:1 withObject:@"0"];
                }
            }
            break;
        case 102:
            {
                NSString *status = _statusArr[btn.tag-100];
                if ([status isEqualToString:@"0"]) {
                    [btn setImage:[UIImage imageNamed:@"slideMenu"] forState:UIControlStateNormal];
                    [_statusArr replaceObjectAtIndex:2 withObject:@"1"];
                }else{
                    [btn setImage:[UIImage imageNamed:@"switchmap"] forState:UIControlStateNormal];
                    [_statusArr replaceObjectAtIndex:2 withObject:@"0"];
                }
            }
            break;
        case 103:
            {
                NSString *status = _statusArr[btn.tag-100];
                if ([status isEqualToString:@"0"]) {
                    [btn setImage:[UIImage imageNamed:@"slideMenu"] forState:UIControlStateNormal];
                    [_statusArr replaceObjectAtIndex:3 withObject:@"1"];
                }else{
                    [btn setImage:[UIImage imageNamed:@"switchmap"] forState:UIControlStateNormal];
                    [_statusArr replaceObjectAtIndex:3 withObject:@"0"];
                }
            }
            break;
        default:
            break;
    }
//    btn.selected = !btn.selected;
}

- (void)pageTitleView:(YQSegmentView *)pageTitleView selectedIndex:(NSInteger)selectedIndex {
    [self.pageContentScrollView setPageCententScrollViewCurrentIndex:selectedIndex];
    notificationName = [NSString stringWithFormat:@"%@%@",@"monitorChangeMapOrListView",self.titleArr[selectedIndex]];
    [kNotificationCenter postNotificationName:@"monitorResignFirstResponder" object:nil];
    
    rightBtn.tag = 100 + selectedIndex;
    
    NSString *status = _statusArr[selectedIndex];
    if ([status isEqualToString:@"0"]) {
        [rightBtn setImage:[UIImage imageNamed:@"switchmap"] forState:UIControlStateNormal];
    }else{
        [rightBtn setImage:[UIImage imageNamed:@"slideMenu"] forState:UIControlStateNormal];
    }
}

- (void)pageContentScrollView:(YQPageContentScrollView *)pageContentScrollView progress:(CGFloat)progress originalIndex:(NSInteger)originalIndex targetIndex:(NSInteger)targetIndex {
    [self.pageTitleView setPageTitleViewWithProgress:progress originalIndex:originalIndex targetIndex:targetIndex];
    notificationName = [NSString stringWithFormat:@"%@%@",@"monitorChangeMapOrListView",self.titleArr[targetIndex]];
    [kNotificationCenter postNotificationName:@"monitorResignFirstResponder" object:nil];
    
    rightBtn.tag = 100 + targetIndex;
    NSString *status = _statusArr[targetIndex];
    if ([status isEqualToString:@"0"]) {
        [rightBtn setImage:[UIImage imageNamed:@"switchmap"] forState:UIControlStateNormal];
    }else{
        [rightBtn setImage:[UIImage imageNamed:@"slideMenu"] forState:UIControlStateNormal];
    }
}

-(void)changeBtnImage:(NSNotification *)notification
{
    NSInteger index = [notification.object integerValue];
    [rightBtn setImage:[UIImage imageNamed:@"switchmap"] forState:UIControlStateNormal];
    [_statusArr replaceObjectAtIndex:index withObject:@"0"];
}

-(void)changeBtnImageToMap:(NSNotification *)notification
{
    [rightBtn setImage:[UIImage imageNamed:@"slideMenu"] forState:UIControlStateNormal];
    NSInteger index = [notification.object integerValue];
    [_statusArr replaceObjectAtIndex:index withObject:@"1"];
}

-(void)changeBtnImageToSlider:(NSNotification *)notification
{
    [rightBtn setImage:[UIImage imageNamed:@"switchmap"] forState:UIControlStateNormal];
    NSInteger index = [notification.object integerValue];
    [_statusArr replaceObjectAtIndex:index withObject:@"0"];
}

-(void)dealloc
{
    [kNotificationCenter removeObserver:self name:@"changeBtnImageNotification" object:nil];
    [kNotificationCenter removeObserver:self name:@"monitorchangeMapBtnImageNotification" object:nil];
    [kNotificationCenter removeObserver:self name:@"monitorchangeSliderBtnImageNotification" object:nil];
}

@end
