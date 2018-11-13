//
//  AirBatchCenViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/7/13.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "AirBatchCenViewController.h"
#import "AirSwitchViewController.h"
#import "AirBatchViewController.h"

@interface AirBatchCenViewController ()<UIScrollViewDelegate>
{
    NSInteger _currentIndex;
    UIButton *rightBtn;
}

@property (nonatomic, weak) UIScrollView *contentScroll;

@property (nonatomic, weak) UIScrollView *titleScroll;

@property (nonatomic, weak) UIButton *selectBtn;

@property (nonatomic, strong) NSMutableArray *titleButton;

@end

@implementation AirBatchCenViewController

- (NSMutableArray *)titleButton
{
    if (_titleButton == nil) {
        _titleButton = [NSMutableArray array];
    }
    return _titleButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:236.0/255.0 green:225.0/255.0 blue:215.0/255.0 alpha:1];
    
    [self setUpContaintScrollView];
    
    [self setUpChildController];
    
    [self setUpTitleScroll];
    
    if (kDevice_Is_iPhoneX) {
        self.contentScroll.contentSize = CGSizeMake(self.childViewControllers.count *KScreenWidth, KScreenHeight-88-34);
    }else{
        self.contentScroll.contentSize = CGSizeMake(self.childViewControllers.count *KScreenWidth, KScreenHeight-kTopHeight);
    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    _currentIndex = 0;
    
    [self initNavItems];
    
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
    rightBtn.hidden = YES;
    rightBtn.frame = CGRectMake(0, 0, 80, 40);
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [rightBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    [rightBtn setTitle:@"全选" forState:UIControlStateNormal];
    [rightBtn setTitle:@"取消全选" forState:UIControlStateSelected];
    [rightBtn addTarget:self action:@selector(_rightBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
}

-(void)_leftBarBtnItemClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)_rightBarBtnItemClick:(UIButton *)button {
    // 全选
    button.selected = !button.selected;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AirALlSelNotification" object:[NSNumber numberWithBool:button.selected]];
}

- (void)setUpTitleScroll
{
    UIScrollView *view = [[UIScrollView alloc] init];
    view.frame = CGRectMake(0, 0, KScreenWidth-210*wScale, 44);
    view.showsHorizontalScrollIndicator = NO;
    self.titleScroll = view;
    CGFloat btnW = (KScreenWidth - 210*wScale)/2;
    CGFloat btnH = view.frame.size.height;
    
    for (int i = 0; i < self.childViewControllers.count; ++i) {
        
        UIViewController *vc = self.childViewControllers[i];
        
        UIButton *btn = [[UIButton alloc] init];
        btn.frame = CGRectMake(btnW * i, 0, btnW, btnH);
        [btn setTitle:vc.title forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithHexString:@"FFFFFF"] forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [btn setAlpha:0.36];
        [btn addTarget:self action:@selector(topTitleBtnClick:) forControlEvents:UIControlEventTouchDown];
        btn.backgroundColor = [UIColor clearColor];
        btn.tag = i;
        
        [view addSubview:btn];
        
        if (btn.tag == 0) {
            [self topTitleBtnClick:btn];
            [btn setAlpha:1];
            [btn.titleLabel setFont:[UIFont systemFontOfSize:17]];
        }
        
        [self.titleButton addObject:btn];
        
    }
    
    self.navigationItem.titleView = view;
    
    self.titleScroll.contentSize = CGSizeMake(btnW *self.childViewControllers.count, 0);
    
}

- (void)topTitleBtnClick:(UIButton *)btn
{
    
    [self selctedBtn:btn];
    
    [self setUpOnechildController:btn];
    
}

- (void)setUpOnechildController:(UIButton *)btn
{
    UIViewController *vc = self.childViewControllers[btn.tag];
    if (kDevice_Is_iPhoneX) {
        vc.view.frame = CGRectMake(btn.tag * KScreenWidth, 0, KScreenWidth, KScreenHeight-88-34);
    }else{
        vc.view.frame = CGRectMake(btn.tag * KScreenWidth, 0, KScreenWidth, KScreenHeight-64);
    }
    
    
    [self.contentScroll addSubview:vc.view];
    
    _currentIndex = btn.tag;
    [UIView animateWithDuration:0.4 animations:^{
        self.contentScroll.contentOffset = CGPointMake(btn.tag *KScreenWidth, 0);
    }];
    
    if(_currentIndex == 0){
        rightBtn.hidden = YES;
    }else {
        rightBtn.hidden = NO;
    }
}

//让标题居中
- (void)setupTitleButtonCenter:(UIButton *)button
{
    // 修改偏移量
    CGFloat offsetX = button.center.x - KScreenWidth * 0.5;
    
    // 处理最小滚动偏移量
    if (offsetX < 0) {
        offsetX = 0;
    }
    
    // 处理最大滚动偏移量
    CGFloat maxOffsetX = self.titleScroll.contentSize.width - KScreenWidth;
    if (offsetX > maxOffsetX) {
        offsetX = maxOffsetX;
    }
    //    [self.titleScroll setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}

- (void)selctedBtn:(UIButton *)btn
{
    if(_selectBtn != btn){
        
        [_selectBtn setAlpha:0.36];
        [btn setAlpha:1];
        
        [_selectBtn.titleLabel  setFont:[UIFont systemFontOfSize:13]];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:17]];
        
        [_selectBtn setBackgroundImage:nil forState:UIControlStateNormal];
        
        [self setupTitleButtonCenter:btn];
        
        _selectBtn = btn;
    }
}

//下面的滚动容器视图
- (void)setUpContaintScrollView
{
    UIScrollView *scroll = [[UIScrollView alloc] init];
    if (kDevice_Is_iPhoneX) {
        scroll.frame = CGRectMake(0, 0,KScreenWidth , KScreenHeight-88-34);
    }else{
        scroll.frame = CGRectMake(0, 0,KScreenWidth , KScreenHeight-64);
    }
    scroll.backgroundColor = [UIColor whiteColor];
    scroll.pagingEnabled = YES;
    scroll.showsHorizontalScrollIndicator = NO;
    scroll.delegate = self;
    scroll.bounces = NO;
    
    [self.view addSubview:scroll];
    self.contentScroll = scroll;
    
}

//添加子控制器
- (void)setUpChildController
{
    //一键开关
    AirSwitchViewController *switchVC = [[AirSwitchViewController alloc] init];
    switchVC.title = @"楼层操控";
    switchVC.menuID = _menuID;
    [self addChildViewController:switchVC];
    
    //批量控制
    AirBatchViewController *batchVC = [[AirBatchViewController alloc] init];
    batchVC.title = @"公司操控";
    [self addChildViewController:batchVC];
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger i = scrollView.contentOffset.x / KScreenWidth;
    
    UIButton *btn = self.titleButton[i];
    if (_currentIndex == i) {
        return;
    }else
    {
        [self selctedBtn:btn];
        
        [self setUpOnechildController:btn];
        _currentIndex = i;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger leftI = scrollView.contentOffset.x / KScreenWidth;
    
    NSInteger rightI = leftI + 1;
    
    // 1.获取需要形变的按钮
    
    // right
    NSUInteger count = self.childViewControllers.count;
    UIButton *rigthButton;
    // 获取右边按钮
    if (rightI < count) {
        rigthButton = self.titleButton[rightI];
    }
    
    // 计算右边按钮偏移量
    CGFloat rightScale = scrollView.contentOffset.x / KScreenWidth;
    // 只想要 0~1
    rightScale = rightScale - leftI;
    
}
@end
