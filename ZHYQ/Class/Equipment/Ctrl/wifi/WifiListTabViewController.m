//
//  WifiListTabViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/15.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "WifiListTabViewController.h"

#import "WifiListTableViewCell.h"

@interface WifiListTabViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    BOOL isOpen;
}

@property (nonatomic, strong)NSIndexPath * selectedIndex;

@end

@implementation WifiListTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    isOpen = YES;
    
    [self _initView];
}

-(void)_initView
{
    [self.view addSubview:self.tableView];
    self.tableView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight-50-64);
    self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.mj_header.hidden = YES;
    self.tableView.mj_footer.hidden = YES;
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    [self.tableView registerNib:[UINib nibWithNibName:@"WifiListTableViewCell" bundle:nil] forCellReuseIdentifier:@"WifiListTableViewCell"];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 8;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WifiListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WifiListTableViewCell" forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (indexPath.row == _selectedIndex.row && _selectedIndex != nil) {
        //如果是展开
        if (isOpen == YES) {
            //xxxxxx
            NSLog(@"new cell");
            cell.contentView.backgroundColor = [UIColor colorWithHexString:@"F8FCFF"];
            cell.selectView.hidden = NO;
            cell.locationLab.hidden = NO;
            cell.locationNumLab.hidden = NO;
            cell.netSepLab.hidden = NO;
            cell.netSepNumLab.hidden = NO;
            cell.sendLab.hidden = NO;
            cell.sendNumLab.hidden = NO;
            cell.userLab.hidden = NO;
            cell.userNumLab.hidden = NO;
            cell.userNumBt.hidden = NO;
        }else{
            //收起
            NSLog(@"old cell");
            cell.contentView.backgroundColor = [UIColor whiteColor];
            cell.selectView.hidden = YES;
            cell.locationLab.hidden = YES;
            cell.locationNumLab.hidden = YES;
            cell.netSepLab.hidden = YES;
            cell.netSepNumLab.hidden = YES;
            cell.sendLab.hidden = YES;
            cell.sendNumLab.hidden = YES;
            cell.userLab.hidden = YES;
            cell.userNumLab.hidden = YES;
            cell.userNumBt.hidden = YES;
        }
        //不是自身
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.selectView.hidden = YES;
        cell.locationLab.hidden = YES;
        cell.locationNumLab.hidden = YES;
        cell.netSepLab.hidden = YES;
        cell.netSepNumLab.hidden = YES;
        cell.sendLab.hidden = YES;
        cell.sendNumLab.hidden = YES;
        cell.userLab.hidden = YES;
        cell.userNumLab.hidden = YES;
        cell.userNumBt.hidden = YES;
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _selectedIndex.row && _selectedIndex != nil ) {
        if (isOpen == YES) {
            return 185;
        }else{
            return 60;
        }
    }
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
    //判断选中不同row状态时候
    //    if (self.selectedIndex != nil && indexPath.row != selectedIndex.row) {
    if (self.selectedIndex != nil && indexPath.row == _selectedIndex.row) {
        //将选中的和所有索引都加进数组中
        //        indexPaths = [NSArray arrayWithObjects:indexPath,selectedIndex, nil];
        isOpen = !isOpen;
        
    }else if (self.selectedIndex != nil && indexPath.row != _selectedIndex.row) {
        indexPaths = [NSArray arrayWithObjects:indexPath,_selectedIndex, nil];
        isOpen = YES;
    }
    //记下选中的索引
    self.selectedIndex = indexPath;
    //刷新
//    [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
