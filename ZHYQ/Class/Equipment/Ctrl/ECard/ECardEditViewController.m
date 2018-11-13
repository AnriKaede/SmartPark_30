//
//  ECardEditViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/11.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "ECardEditViewController.h"
#import "OpenDoorAreaViewController.h"
#import "ParkRecordCenViewController.h"
#import "CardUserInfoCell.h"

#import "FindCarNoModel.h"
#import "Utils.h"

#import "BookRecordViewController.h"
#import "AttendanceDetailViewController.h"
#import "CardRecordViewController.h"
#import "VisitRecordViewController.h"

@interface ECardEditViewController ()
{
    NSMutableArray *_infoData;
    NSMutableArray *_bindCarData;
}
@end

@implementation ECardEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _infoData = @[].mutableCopy;
    _bindCarData = @[].mutableCopy;
    
    [self _initView];
    
    [self fullData];
    
    [self addUserInfoMenu];
    
    [self _loadCarNoInfo];
}

- (void)_initView {
    self.title = @"员工信息";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.tableView.tableFooterView = [UIView new];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CardUserInfoCell" bundle:nil] forCellReuseIdentifier:@"CardUserInfoCell"];
    
}
- (void)fullData {
    // 填充数据
    if(_eCardInfoModel.basePerName != nil && ![_eCardInfoModel.basePerName isKindOfClass:[NSNull class]]){
        [_infoData addObject:@{@"title":@"姓名",
                               @"info":_eCardInfoModel.basePerName,
                               @"editFlag":@0
                               }];
    }
    if(_eCardInfoModel.companyName != nil && ![_eCardInfoModel.companyName isKindOfClass:[NSNull class]]){
        [_infoData addObject:@{@"title":@"公司",
                               @"info":_eCardInfoModel.companyName,
                               @"editFlag":@0
                               }];
    }
    if(_eCardInfoModel.departName != nil && ![_eCardInfoModel.departName isKindOfClass:[NSNull class]]){
        [_infoData addObject:@{@"title":@"部门",
                               @"info":_eCardInfoModel.departName,
                               @"editFlag":@0
                               }];
    }
    [_infoData addObject:@{@"title":@"开门区域",
                           @"info":@"",
                           @"editFlag":@1
                           }];
    if(_eCardInfoModel.basePerNo != nil && ![_eCardInfoModel.basePerNo isKindOfClass:[NSNull class]]){
        [_infoData addObject:@{@"title":@"卡号",
                               @"info":_eCardInfoModel.basePerNo,
                               @"editFlag":@0
                               }];
    }
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)_rightBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_loadCarNoInfo {
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/getCarInfo", Main_Url];
    
    NSMutableDictionary *param = @{}.mutableCopy;
    [param setObject:_eCardInfoModel.basePerNo forKey:@"workNumber"];
    [param setObject:@"1" forKey:@"pageNumber"];
    [param setObject:@"10" forKey:@"pageSize"];
    
    NSString *jsonStr = [Utils convertToJsonData:param];
    NSDictionary *paramJson = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:paramJson progressFloat:nil succeed:^(id responseObject) {
        if(responseObject[@"code"] != nil && ![responseObject[@"code"] isKindOfClass:[NSNull class]] && [responseObject[@"code"] isEqualToString:@"1"]){
            
            NSArray *data = responseObject[@"responseData"];
            if(data != nil && ![data isKindOfClass:[NSNull class]] && data.count > 0){
                [data enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    FindCarNoModel *model = [[FindCarNoModel alloc] initWithDataDic:obj];
                    [_bindCarData addObject:model];
                    
                    NSString *colorStr;
                    if(model.CARD_CARCOLOR == nil || [model.CARD_CARCOLOR isKindOfClass:[NSNull class]] || model.CARD_CARCOLOR.length <= 0){
                        colorStr = @"";
                    }else {
                        colorStr = [NSString stringWithFormat:@"(%@)", model.CARD_CARCOLOR];
                    }
                    NSString *carInfo = [NSString stringWithFormat:@"%@%@", model.CAR_NO, colorStr];
                    
                    [_infoData insertObject:@{@"title":@"绑定车辆",
                                              @"info":carInfo,
                                              @"editFlag":@1
                                              } atIndex:5+idx];
                }];
                
            }else {
                [_infoData insertObject:@{@"title":@"绑定车辆",
                                          @"info":@"无",
                                          @"editFlag":@0
                                          } atIndex:5];
            }
            
        }else {
            [_infoData insertObject:@{@"title":@"绑定车辆",
                                      @"info":@"无",
                                      @"editFlag":@0
                                      } atIndex:5];
            
            if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
                [self showHint:responseObject[@"message"]];
            }
        }
        
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [_infoData insertObject:@{@"title":@"绑定车辆",
                                  @"info":@"无",
                                  @"editFlag":@0
                                  } atIndex:5];
        [self.tableView reloadData];
    }];
}

- (void)addUserInfoMenu {
    NSArray *titleAry = @[@"车位预约明细", @"工作考勤明细",@"园区消费明细",@"访客预约明细"];
    [titleAry enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL * _Nonnull stop) {
        [_infoData addObject:@{@"title":title,
                               @"info":@"",
                               @"editFlag":@1
                               }];
    }];
}

#pragma mark UITableView协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _infoData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 61;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CardUserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CardUserInfoCell" forIndexPath:indexPath];
    if(_infoData.count > indexPath.row){
        cell.infoDic = _infoData[indexPath.row];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 3){
        // 开门区域
        OpenDoorAreaViewController *openDoorVC = [[OpenDoorAreaViewController alloc] init];
        openDoorVC.basePerNo = _eCardInfoModel.basePerNo;
        [self.navigationController pushViewController:openDoorVC animated:YES];
    }else if (indexPath.row >= 5 && indexPath.row < [self getRecordIndex]) {
        if(_bindCarData.count > indexPath.row - 5){
            FindCarNoModel *findCarNoModel = _infoData[indexPath.row - 5];
            
            ParkRecordCenViewController *parkRecordCenVC = [[ParkRecordCenViewController alloc] init];
            parkRecordCenVC.carNo = [NSString stringWithFormat:@"%@", findCarNoModel.CAR_NO];
            [self.navigationController pushViewController:parkRecordCenVC animated:YES];
        }
    }else if(indexPath.row == [self getRecordIndex]){
        // 车位预约明细
        BookRecordViewController *recordVC = [[BookRecordViewController alloc] init];
        recordVC.title = @"车位预约明细";
        recordVC.cardNo = _eCardInfoModel.basePerNo;
        [self.navigationController pushViewController:recordVC animated:YES];
    }else if(indexPath.row == [self getRecordIndex] + 1){
        // 工作考勤明细
        AttendanceDetailViewController *recordVC = [[AttendanceDetailViewController alloc] init];
        recordVC.title = @"工作考勤明细";
        recordVC.cardNo = _eCardInfoModel.basePerNo;
        [self.navigationController pushViewController:recordVC animated:YES];
    }else if(indexPath.row == [self getRecordIndex] + 2){
        // 园区消费明细
        CardRecordViewController *recordVC = [[CardRecordViewController alloc] init];
        recordVC.title = @"园区消费明细";
        recordVC.cardNo = _eCardInfoModel.basePerNo;
        [self.navigationController pushViewController:recordVC animated:YES];
    }else if(indexPath.row == [self getRecordIndex] + 3){
        // 访客预约明细
        VisitRecordViewController *recordVC = [[VisitRecordViewController alloc] init];
        recordVC.title = @"访客预约明细";
        recordVC.cardNo = _eCardInfoModel.basePerNo;
        [self.navigationController pushViewController:recordVC animated:YES];
    }
}

// 获取绑定车辆下面明细开始 行数
- (NSInteger)getRecordIndex {
    NSInteger index = 6;
    if(_bindCarData.count <= 0 && _infoData.count >= 10){
        index = 6;
    }else {
        index = _infoData.count - 4 - _bindCarData.count;
    }
    return index;
}

@end
