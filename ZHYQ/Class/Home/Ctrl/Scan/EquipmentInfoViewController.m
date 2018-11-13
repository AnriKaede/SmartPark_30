//
//  EquipmentInfoViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/4/24.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "EquipmentInfoViewController.h"
#import "CalculateHeight.h"
#import "ScanNoDataView.h"
#import "ReportAlertView.h"

@interface EquipmentInfoViewController ()<ReportAlertDelegate>
{
    __weak IBOutlet UILabel *_nameLabel;
    __weak IBOutlet UILabel *_numLabel;
    __weak IBOutlet UILabel *_introductionLabel;
    
    __weak IBOutlet UIImageView *_equipmentImgView;
    
    __weak IBOutlet UIView *_reportBgView;
    __weak IBOutlet UIButton *_submitBt;
    
    ScanNoDataView *_scanNoDataView;
    BOOL _isNodata;
    ReportAlertView *_reportAlertView;
}
@end

@implementation EquipmentInfoViewController

- (ReportAlertView *)reportAlertView {
    if(_reportAlertView == nil){
        _reportAlertView = [[ReportAlertView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, self.view.height)];
        _reportAlertView.reportDelegate = self;
        [self.view addSubview:_reportAlertView];
    }
    return _reportAlertView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    _isNodata = YES;
    
    [self _initView];
}

- (void)_initView {
    self.title = @"设备信息";
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    
    _scanNoDataView = [[ScanNoDataView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, self.tableView.height)];
    _scanNoDataView.hidden = YES;
    self.tableView.backgroundView = _scanNoDataView;
    
    _submitBt.layer.cornerRadius = 4;
    _submitBt.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
    _submitBt.layer.borderWidth = 0.8;

    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITableView协议
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(!_isNodata){
        switch (indexPath.row) {
            case 2:
            {
                CGFloat labelHeight = [CalculateHeight heightForString:@"设备简介设备简介设备简介设备简介设备简介设备简介设备简介设备设备简介设备简介设备简介设备简介简介设备简介设备简介设备简介" fontSize:17 andWidth:KScreenWidth - 120];
                return 45 + labelHeight;
                break;
            }
                
            case 3:
            {
                return 210;
                break;
            }
                
            default:
                return 60;
                break;
        }
    }else {
        _reportBgView.hidden = YES;
        _scanNoDataView.hidden = NO;
        return 0.1;
    }
}

- (IBAction)submitAction:(id)sender {
    [self reportAlertView];
    
    // 显示
    [_reportAlertView showReport:@""];
}

#pragma mark ReportAlertDelegate
- (void)cancel {
    [_reportAlertView hidReport];
}

- (void)submitReport {
    
}

@end
