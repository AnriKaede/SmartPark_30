//
//  WarnBaseViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/4/25.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "WarnBaseViewController.h"

@interface WarnBaseViewController ()
{
    
}
@end

@implementation WarnBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(conPointZero) name:@"WarnTopShowHeader" object:nil];
}

- (instancetype)initWithHeaderHeight:(CGFloat)height {
    self = [super init];
    if(self){
        _headerHeight = height;
        
        [self _initView];
    }
    return self;
}

- (void)conPointZero {
    [self.warnTableView setContentOffset:CGPointMake(0, 0) animated:NO];
}

- (void)_initView {
    
    self.warnTableView.showsVerticalScrollIndicator = NO;
    self.warnTableView.showsHorizontalScrollIndicator = NO;
}

#pragma mark UITableView协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return _headerHeight;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
//    return _headerHeight;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    return cell;
}


#pragma mark UIScrollView协议
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(scrollView.contentOffset.y <= 0){
//        scrollView.contentOffset = CGPointMake(0, 0);
        
    }else {
        
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if(_scrollStopDelegate && [_scrollStopDelegate respondsToSelector:@selector(stopScroll:)]){
        [_scrollStopDelegate stopScroll:scrollView.contentOffset.y];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(!decelerate){
        if(_scrollStopDelegate && [_scrollStopDelegate respondsToSelector:@selector(stopScroll:)]){
            [_scrollStopDelegate stopScroll:scrollView.contentOffset.y];
        }
    }
}

@end
