//
//  LauchViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/3/19.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "LauchViewController.h"

@interface LauchViewController ()<UIScrollViewDelegate>
{
    UIScrollView *_bgScrollView;
    
    UIPageControl *_pageControl;
}
@end

@implementation LauchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
}

- (void)_initView {
    _bgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    _bgScrollView.delegate = self;
    _bgScrollView.contentSize = CGSizeMake(KScreenWidth*3, 0);
    _bgScrollView.showsHorizontalScrollIndicator = NO;
    _bgScrollView.showsVerticalScrollIndicator = NO;
    _bgScrollView.pagingEnabled = YES;
    [self.view addSubview:_bgScrollView];
    
    for (int i=1; i<=3; i++) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(KScreenWidth * (i-1), 0, KScreenWidth, KScreenHeight)];
        if(kDevice_Is_iPhoneX){
            imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"lauch_x_0%d", i]];
        }else {
            imgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"lauch_0%d", i]];
        }
        [_bgScrollView addSubview:imgView];
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(KScreenWidth*2 + (KScreenWidth - 130)/2, KScreenHeight - 100*hScale, 130*wScale, 50);
    button.backgroundColor = [UIColor whiteColor];
    [button setTitle:@"立即体验" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithHexString:@"#0B82D1"] forState:UIControlStateNormal];
    button.layer.cornerRadius = 4;
    button.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
    button.layer.borderWidth = 0.6;
    [button addTarget:self action:@selector(skipAction) forControlEvents:UIControlEventTouchUpInside];
    [_bgScrollView addSubview:button];
    
    _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(KScreenWidth / 3, KScreenHeight * 15 / 16, KScreenWidth / 3, KScreenHeight / 16)];
    
    _pageControl.numberOfPages = 3;
    _pageControl.pageIndicatorTintColor = [UIColor colorWithHexString:@"#E2E2E2"];
    _pageControl.currentPageIndicatorTintColor = [UIColor colorWithHexString:@"#0B82D1"];
    [self.view addSubview:_pageControl];
}

- (void)skipAction {
    // 下次不显示引导页
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KFirstLauch];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate initWindow];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _pageControl.currentPage = scrollView.contentOffset.x/KScreenWidth;
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    _pageControl.currentPage = scrollView.contentOffset.x/KScreenWidth;
}
// 停止拖拽
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(scrollView.contentOffset.x > KScreenWidth*2.15){
        [self skipAction];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
