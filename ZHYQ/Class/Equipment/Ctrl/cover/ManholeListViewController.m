//
//  ManholeListViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/15.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "ManholeListViewController.h"

#import "ManholeListTableViewCell.h"

@interface ManholeListViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    BOOL isOpen;
}

@property (nonatomic, strong) NSIndexPath * selectedIndex;

@end

@implementation ManholeListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isOpen = YES;
    
    [self _initNavItems];
    
    [self _initView];
}

-(void)_initNavItems
{
    self.title = @"井盖列表";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIButton *rightBtn = [[UIButton alloc] init];
    rightBtn.frame = CGRectMake(0, 0, 40, 40);
    [rightBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    [rightBtn setImage:[UIImage imageNamed:@"search_icon"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(_rightBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
}

-(void)_initView
{
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.mj_header.hidden = YES;
    self.tableView.mj_footer.hidden = YES;
    self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ManholeListTableViewCell" bundle:nil] forCellReuseIdentifier:@"ManholeListTableViewCell"];
    self.tableView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight-64);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ManholeListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ManholeListTableViewCell" forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (indexPath.row == _selectedIndex.row && _selectedIndex != nil) {
        //如果是展开
        if (isOpen == YES) {
            //xxxxxx
            NSLog(@"new cell");
            cell.contentView.backgroundColor = [UIColor colorWithHexString:@"F8FCFF"];
            cell.selectView.hidden = NO;
            cell.holeLocationLab.hidden = NO;
            cell.holeAreaLab.hidden = NO;
            cell.holeLockLab.hidden = NO;
            cell.lockBtn.hidden = NO;
            cell.holeNumLab.hidden = NO;
            cell.holeNumDetailLab.hidden = NO;
            
        }else{
            //收起
            NSLog(@"old cell");
            cell.contentView.backgroundColor = [UIColor whiteColor];
            cell.selectView.hidden = YES;
            cell.holeLocationLab.hidden = YES;
            cell.holeAreaLab.hidden = YES;
            cell.holeLockLab.hidden = YES;
            cell.lockBtn.hidden = YES;
            cell.holeNumLab.hidden = YES;
            cell.holeNumDetailLab.hidden = YES;
        }
        //不是自身
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.selectView.hidden = YES;
        cell.holeLocationLab.hidden = YES;
        cell.holeAreaLab.hidden = YES;
        cell.holeLockLab.hidden = YES;
        cell.lockBtn.hidden = YES;
        cell.holeNumLab.hidden = YES;
        cell.holeNumDetailLab.hidden = YES;
    }
    
    cell.model = self.dataArr[indexPath.row];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _selectedIndex.row && _selectedIndex != nil ) {
        if (isOpen == YES) {
            return 210;
        }else{
            return 60;
        }
    }
    return 60;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *indexPaths = @[].mutableCopy;
    if(indexPath.row < self.dataArr.count){
        [indexPaths addObject:indexPath];
    }
    //判断选中不同row状态时候
    //    if (self.selectedIndex != nil && indexPath.row != selectedIndex.row) {
    if (self.selectedIndex != nil && indexPath.row == _selectedIndex.row) {
        //将选中的和所有索引都加进数组中
        //        indexPaths = [NSArray arrayWithObjects:indexPath,selectedIndex, nil];
        isOpen = !isOpen;
        
    }else if (self.selectedIndex != nil && indexPath.row != _selectedIndex.row) {
        if(_selectedIndex.row < self.dataArr.count){
            [indexPaths addObject:_selectedIndex];
        }
        isOpen = YES;
        
    }
    //记下选中的索引
    self.selectedIndex = indexPath;
    //刷新
    [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
}

-(void)_leftBarBtnItemClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)_rightBarBtnItemClick:(id)sender
{
    
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
