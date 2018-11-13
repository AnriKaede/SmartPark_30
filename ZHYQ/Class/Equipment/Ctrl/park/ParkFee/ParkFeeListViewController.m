//
//  ParkFeeListViewController.m
//  ZHYQ
//
//  Created by coder on 2018/10/24.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "ParkFeeListViewController.h"
#import "ParkFeeListCell.h"
#import "ParkFeeDetailViewController.h"
#import "ParkFeeFilterView.h"

@interface ParkFeeListViewController ()<ParkFeeFaliterPopViewDelegate>

@property (nonatomic,retain) ParkFeeFilterView *filterView;

@end

@implementation ParkFeeListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initNav];
    
    [self initView];
}

-(void)initNav{
    self.title = @"收费明细";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIButton *rightBtn = [[UIButton alloc] init];
    rightBtn.frame = CGRectMake(0, 0, 40, 40);
    [rightBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    [rightBtn setImage:[UIImage imageNamed:@"nav_filter_icon"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(_rightBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)_rightBarBtnItemClick
{
    if (_filterView.isShow) {
        return;
    }
    _filterView = [[ParkFeeFilterView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    //显示
    _filterView.delegate = self;
    [_filterView showInView:self.view];
}

-(void)initView{
    [self.tableView registerNib:[UINib nibWithNibName:@"ParkFeeListCell" bundle:nil] forCellReuseIdentifier:@"ParkFeeListCell"];
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ParkFeeListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ParkFeeListCell" forIndexPath:indexPath];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 75;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithHexString:@"#EFEFEF"];
    
    UILabel *timeLab = [[UILabel alloc] initWithFrame:CGRectMake(9, 16, 120, 18)];
    timeLab.text = @"2017年12月";
    timeLab.textColor = [UIColor colorWithHexString:@"#333333"];
    timeLab.textAlignment = NSTextAlignmentLeft;
    timeLab.font = [UIFont systemFontOfSize:17];
    [view addSubview:timeLab];
    
    UILabel *incomeLab = [[UILabel alloc] initWithFrame:CGRectMake(9, timeLab.bottom + 11, 120, 18)];
    incomeLab.text = @"收入1234.0元";
    incomeLab.textColor = [UIColor colorWithHexString:@"#333333"];
    incomeLab.textAlignment = NSTextAlignmentLeft;
    incomeLab.font = [UIFont systemFontOfSize:16];
    [view addSubview:incomeLab];
    
    return view;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ParkFeeDetailViewController *parkFeeDetailVc = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"ParkFeeDetailViewController"];
    [self.navigationController pushViewController:parkFeeDetailVc animated:YES];
}

@end
