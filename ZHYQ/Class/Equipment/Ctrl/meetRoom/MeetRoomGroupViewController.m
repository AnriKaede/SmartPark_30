//
//  MeetRoomGroupViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/7/24.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "MeetRoomGroupViewController.h"
#import "MeetRoomCell.h"
#import "MeetPageViewController.h"
#import "MeetRoomGroupModel.h"

@interface MeetRoomGroupViewController ()<UITableViewDelegate, UITableViewDataSource, CYLTableViewPlaceHolderDelegate>
{
    UITableView *_groupTableView;
    
    NSMutableArray *_groupData;
}
@end

@implementation MeetRoomGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _groupData = @[].mutableCopy;
    
    [self _initView];
    
    [self _loadData];
}

- (void)_initView {
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _groupTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64) style:UITableViewStylePlain];
    _groupTableView.delegate = self;
    _groupTableView.dataSource = self;
    _groupTableView.tableFooterView = [UIView new];
    [self.view addSubview:_groupTableView];
    [_groupTableView registerNib:[UINib nibWithNibName:@"MeetRoomCell" bundle:nil] forCellReuseIdentifier:@"MeetRoomCell"];
    
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_loadData {
    // equipment/getMeetingList
    NSString *urlStr = [NSString stringWithFormat:@"%@/equipment/getMeetingList", Main_Url];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            NSArray *meetRoomList = responseObject[@"responseData"][@"meetRoomList"];
            [_groupData removeAllObjects];
            [meetRoomList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                MeetRoomGroupModel *model = [[MeetRoomGroupModel alloc] initWithDataDic:obj];
                [_groupData addObject:model];
            }];
            [_groupTableView cyl_reloadData];
        }else {
            NSString *message = responseObject[@"message"];
            if(message != nil && ![message isKindOfClass:[NSNull class]]){
                [self showHint:message];
            }
        }
        
    } failure:^(NSError *error) {
        
    }];
}
#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 60, KScreenWidth, KScreenHeight - kTopHeight)];
    return noDataView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

#pragma mark UITableView协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _groupData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MeetRoomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MeetRoomCell" forIndexPath:indexPath];
    cell.model = _groupData[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MeetPageViewController *meetPageVC = [[MeetPageViewController alloc] init];
    meetPageVC.title = self.title;
    meetPageVC.model = _groupData[indexPath.row];
    [self.navigationController pushViewController:meetPageVC animated:YES];
}

@end
