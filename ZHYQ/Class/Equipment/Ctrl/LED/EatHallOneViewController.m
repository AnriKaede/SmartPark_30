//
//  EatHallOneViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "EatHallOneViewController.h"
#import "LEDDetailCell.h"

@interface EatHallOneViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_eatHallOneTableView;
    
    NSMutableArray *_eatHallOneData;
}
@end

@implementation EatHallOneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _eatHallOneData = @[].mutableCopy;
    
    [self _initView];
}

- (void)_initView {
    _eatHallOneTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 60 - 64) style:UITableViewStyleGrouped];
    _eatHallOneTableView.dataSource = self;
    _eatHallOneTableView.delegate = self;
    [self.view addSubview:_eatHallOneTableView];
    
    [_eatHallOneTableView registerNib:[UINib nibWithNibName:@"LEDDetailCell" bundle:nil] forCellReuseIdentifier:@"LEDDetailCell"];
}

#pragma mark UItableView 协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    //    return _devData.count;
    return 5;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 180;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LEDDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LEDDetailCell" forIndexPath:indexPath];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
