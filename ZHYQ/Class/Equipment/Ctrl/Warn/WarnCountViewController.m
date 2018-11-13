//
//  WarnCountViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/20.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "WarnCountViewController.h"
#import "WarnCountCell.h"

@interface WarnCountViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_warnCountTableView;
    
    NSMutableArray *_warnData;
}
@end

@implementation WarnCountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _warnData = @[@"",@"",@"",@""].mutableCopy;
    
    [self _initView];
}

- (void)_initView {
    
    
    _warnCountTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64 - kTabBarHeight) style:UITableViewStyleGrouped];
    _warnCountTableView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    _warnCountTableView.dataSource = self;
    _warnCountTableView.delegate = self;
    [self.view addSubview:_warnCountTableView];
    [_warnCountTableView registerNib:[UINib nibWithNibName:@"WarnCountCell" bundle:nil] forCellReuseIdentifier:@"WarnCountCell"];
}

#pragma mark UITableView 协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 5;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 530;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WarnCountCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WarnCountCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
