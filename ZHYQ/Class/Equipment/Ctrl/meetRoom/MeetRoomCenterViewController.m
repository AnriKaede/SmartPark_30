//
//  MeetRoomCenterViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/15.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "MeetRoomCenterViewController.h"

#import "SingleControlViewController.h"
#import "MeetRoomViewController.h"
#import "MeetWebViewController.h"

@interface MeetRoomCenterViewController ()<SGPageTitleViewDelegate,YQPageContentScrollViewDelegate>
{
    SingleControlViewController *_singleCtrlVC;
    
    NSString *_aloneTitle;
}
@property (nonatomic, strong) YQSegmentView *pageTitleView;
@property (nonatomic, strong) YQPageContentScrollView *pageContentScrollView;

@property (nonatomic, strong) NSMutableArray *titleArr;

@end

@implementation MeetRoomCenterViewController

-(NSMutableArray *)titleArr
{
    if (_titleArr == nil) {
        _titleArr = [NSMutableArray array];
    }
    return _titleArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self initNavItems];
    
    [self _initView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSceneModel:) name:@"changeSceneModel" object:nil];

}
- (void)changeSceneModel:(NSNotification *)notification {
    NSString *modelId = notification.userInfo[@"modelId"];
    
    if([modelId isEqualToString:@"outing"]){
        // 离场模式
        _aloneTitle = @"离场模式";
    }else if([modelId isEqualToString:@"meeting"]){
        // 会议模式
        _aloneTitle = @"会议模式";
    }else if([modelId isEqualToString:@"shadowing"]){
        // 投影模式
        _aloneTitle = @"演示模式";
    }
}

-(void)_initView
{
    _aloneTitle = @"单独控制";
    NSArray *arr = @[@"720度全景", _aloneTitle,@"场景模式"];
    [self.titleArr addObjectsFromArray:arr];
    
    YQSegmentConfigure *configure = [YQSegmentConfigure pageTitleViewConfigure];
    configure.indicatorColor = [UIColor clearColor];
    configure.titleColor = [UIColor colorWithHexString:@"a8c7e9"];
    configure.titleSelectedColor = [UIColor whiteColor];
    
    /// pageTitleView
    self.pageTitleView = [YQSegmentView pageTitleViewWithFrame:CGRectMake(0, 0, 200*wScale, 44) delegate:self titleNames:self.titleArr configure:configure];
    self.navigationItem.titleView = _pageTitleView;
    _pageTitleView.backgroundColor = [UIColor clearColor];
    _pageTitleView.isTitleGradientEffect = YES;
    _pageTitleView.isNeedBounces = NO;
    _pageTitleView.isOpenTitleTextZoom = YES;
    _pageTitleView.isShowIndicator = NO;
    _pageTitleView.isShowBottomSeparator = NO;
    
    NSMutableArray *childVCs = [[NSMutableArray alloc]init];
    
    MeetWebViewController *meetWebVC = [[MeetWebViewController alloc] init];
    meetWebVC.title = @"720度全景";
    [childVCs addObject:meetWebVC];
    
//    SingleControlViewController *singleCtrlVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"SingleControlViewController"];
    _singleCtrlVC = [[SingleControlViewController alloc] init];
    _singleCtrlVC.title = @"单独控制";
    [childVCs addObject:_singleCtrlVC];
    
    MeetRoomViewController *meetRoomVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"MeetRoomViewController"];
    meetRoomVC.title = @"场景模式";
    [childVCs addObject:meetRoomVC];
    
    /// pageContentView
    self.pageContentScrollView = [[YQPageContentScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, KScreenHeight-64) parentVC:self childVCs:childVCs];
    self.pageContentScrollView.isScrollEnabled = NO;
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
    
}

-(void)_leftBarBtnItemClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pageTitleView:(YQSegmentView *)pageTitleView selectedIndex:(NSInteger)selectedIndex {
    [self.pageContentScrollView setPageCententScrollViewCurrentIndex:selectedIndex];
}

- (void)pageContentScrollView:(YQPageContentScrollView *)pageContentScrollView progress:(CGFloat)progress originalIndex:(NSInteger)originalIndex targetIndex:(NSInteger)targetIndex {
    [self.pageTitleView setPageTitleViewWithProgress:progress originalIndex:originalIndex targetIndex:targetIndex];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"changeSceneModel" object:nil];
}

@end
