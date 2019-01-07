//
//  ParkOverViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/9/19.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "ParkOverViewController.h"
#import "CarRoundView.h"
#import "UnOnlineHomeViewController.h"
#import "WranHomeCenViewController.h"
#import "CloseEqHomeViewController.h"
#import "CheckHomeCenViewController.h"

@interface ParkOverViewController ()
{
    __weak IBOutlet UILabel *_onlineNumLabel;
    __weak IBOutlet UILabel *_offlineNumLabel;
    __weak IBOutlet CarRoundView *_onlineRoundView;
    
    __weak IBOutlet UIView *_wranBgView;
    __weak IBOutlet UILabel *_wramAllNumLabel;
    __weak IBOutlet NSLayoutConstraint *_wramViewWidth; // all screen.widht - 267.5
    __weak IBOutlet UILabel *_wramNumLabel;
    __weak IBOutlet NSLayoutConstraint *_aplViewWidth;
    __weak IBOutlet UILabel *_aplWramNumLabel;
    __weak IBOutlet NSLayoutConstraint *_otherViewWidth;
    __weak IBOutlet UILabel *_otherWramNumLabel;
    
    __weak IBOutlet UILabel *_openNumLabel;
    __weak IBOutlet UILabel *_closeNumLabel;
    __weak IBOutlet CarRoundView *_openRoundView;
    
    __weak IBOutlet UIView *_checkBgView;
    __weak IBOutlet UILabel *_checkAllNumLabel;
    __weak IBOutlet NSLayoutConstraint *_dealViewWidth; // all screen.widht - 254
    __weak IBOutlet UILabel *_dealNumLabel;
    __weak IBOutlet NSLayoutConstraint *_waitViewWidth;
    __weak IBOutlet UILabel *_waitWramNumLabel;
    __weak IBOutlet NSLayoutConstraint *_unDealViewWidth;
    __weak IBOutlet UILabel *_unDealWramNumLabel;
    
    NSArray *_titleData;
}
@end

@implementation ParkOverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"园区概况";
    
    [self _initView];
    
}

- (void)_initView {
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    _titleData = @[@"连接数据", @"告警数据", @"在用数据", @"巡检任务"];
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _wranBgView.layer.cornerRadius = 5;
    _checkBgView.layer.cornerRadius = 5;
    
//    _onlineRoundView.freParkNum = _freNumPark.integerValue;
//    _onlineRoundView.maintainEndNum = (_allNumPark.floatValue - _freNumPark.floatValue)/_allNumPark.floatValue;
    _onlineRoundView.freParkNum = 5;
    _onlineRoundView.maintainEndNum = 0.75;
    [_onlineRoundView setDataTitle:[NSString stringWithFormat:@"%.0f%%", 0.75*100]];
    [_onlineRoundView setSubTitle:@"在线率"];
    
    _openRoundView.freParkNum = 10;
    _openRoundView.maintainEndNum = 0.65;
    [_openRoundView setDataTitle:[NSString stringWithFormat:@"%.0f%%", 0.65*100]];
    [_openRoundView setSubTitle:@"使用率"];
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITableView协议
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(section == 3){
        return 40;
    }else {
        return 0.1;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 40)];
    footerView.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 40)];
    label.text = @"数据截止至2018-08-08 00:00:00";
    label.textColor = [UIColor colorWithHexString:@"#C4C4C4"];
    label.font = [UIFont systemFontOfSize:13];
    label.textAlignment = NSTextAlignmentCenter;
    [footerView addSubview:label];
    
    if(section == 3){
        return footerView;
    }else {
        return [UIView new];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 40)];
    headerView.backgroundColor = [UIColor clearColor];
    
    UILabel *pointLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,35/2, 5, 5)];
    pointLabel.backgroundColor = [UIColor blackColor];
    [headerView addSubview:pointLabel];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(pointLabel.right + 6, 0, 100, 40)];
    label.text = _titleData[section];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:17];
    label.textAlignment = NSTextAlignmentLeft;
    [headerView addSubview:label];
    
    UIImageView *flagImgView = [[UIImageView alloc] initWithFrame:CGRectMake(KScreenWidth - 31, 10, 20, 20)];
    flagImgView.image = [UIImage imageNamed:@"door_list_right_narrow"];
    [headerView addSubview:flagImgView];
    
    return headerView;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
        {
            UnOnlineHomeViewController *onLineVC = [[UnOnlineHomeViewController alloc] init];
            onLineVC.title = @"离线设备";
            [self pushVC:onLineVC];
            break;
        }
        case 1:
        {
            WranHomeCenViewController *wranVC = [[WranHomeCenViewController alloc] init];
            wranVC.title = @"告警数据";
            [self pushVC:wranVC];
            break;
        }
        case 2:
        {
            CloseEqHomeViewController *closeVC = [[CloseEqHomeViewController alloc] init];
            closeVC.title = @"关闭设备";
            [self pushVC:closeVC];
            break;
        }
        case 3:
        {
            CheckHomeCenViewController *checkVC = [[CheckHomeCenViewController alloc] init];
            checkVC.title = @"巡检任务";
            [self pushVC:checkVC];
            break;
        }
            
        default:
            break;
    }
}

- (void)pushVC:(UIViewController *)viewCon {
    [self.navigationController pushViewController:viewCon animated:YES];
}

@end
