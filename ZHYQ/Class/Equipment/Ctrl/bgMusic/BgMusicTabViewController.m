//
//  BgMusicTabViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/16.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "BgMusicTabViewController.h"
#import "BgMusicListTabViewCell.h"
#import "YQSlider.h"
#import <WMPageController.h>
#import "TopMenuModel.h"

@interface BgMusicTabViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    BOOL isOpen;
}

@property (nonatomic, strong)NSIndexPath * selectedIndex;

@end

@implementation BgMusicTabViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    isOpen = YES;
    
    [self _initView];
    
    [self _loadData];
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
    [self.tableView registerNib:[UINib nibWithNibName:@"BgMusicListTabViewCell" bundle:nil] forCellReuseIdentifier:@"BgMusicListTabViewCell"];
    
}

-(void)_loadData
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/public/getChildBulidingList?bulidId=%@",Main_Url,_model.BUILDING_ID];
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        DLog(@"%@",responseObject);
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            
        }
    } failure:^(NSError *error) {
        
    }];
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
    BgMusicListTabViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BgMusicListTabViewCell" forIndexPath:indexPath];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (indexPath.row == _selectedIndex.row && _selectedIndex != nil) {
        //如果是展开
        if (isOpen == YES) {
            //xxxxxx
            NSLog(@"new cell");
            cell.contentView.backgroundColor = [UIColor colorWithHexString:@"F8FCFF"];
            cell.selectView.hidden = NO;
            cell.currentMusicLab.hidden = NO;
            cell.currentMusicDetailLab.hidden = NO;
            cell.changeMusicBtn.hidden = NO;
            cell.volumeAdjustLab.hidden = NO;
            cell.volumeAdjustSlider.hidden = NO;
        }else{
            //收起
            NSLog(@"old cell");
            cell.contentView.backgroundColor = [UIColor whiteColor];
            cell.selectView.hidden = YES;
            cell.currentMusicLab.hidden = YES;
            cell.currentMusicDetailLab.hidden = YES;
            cell.changeMusicBtn.hidden = YES;
            cell.volumeAdjustLab.hidden = YES;
            cell.volumeAdjustSlider.hidden = YES;
        }
        //不是自身
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.selectView.hidden = YES;
        cell.currentMusicLab.hidden = YES;
        cell.currentMusicDetailLab.hidden = YES;
        cell.changeMusicBtn.hidden = YES;
        cell.volumeAdjustLab.hidden = YES;
        cell.volumeAdjustSlider.hidden = YES;
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _selectedIndex.row && _selectedIndex != nil ) {
        if (isOpen == YES) {
            return 155;
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
    [tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
