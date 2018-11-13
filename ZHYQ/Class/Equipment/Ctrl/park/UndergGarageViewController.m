//
//  UndergGarageViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "UndergGarageViewController.h"
#import "YQSecondHeaderView.h"
#import "ShowMenuView.h"

#import "YQInDoorPointMapView.h"
#import "YQSearchBar.h"

#import "DownParkMdel.h"
#import "SeatStatusModel.h"
#import "ParkCardModel.h"

#import "ImgBrowerViewController.h"

#import "MsgView.h"

@interface UndergGarageViewController ()<MenuControlDelegate,DidSelInMapPopDelegate,UISearchBarDelegate>
{
    YQInDoorPointMapView *indoorView;
    
    NSMutableArray *_parkData;
    NSMutableArray *_graphData;
    
    // 弹窗
    ShowMenuView *_showMenuView;
    NSString *_menuTitle;   // 菜单标题
    NSString *_carLocationNum;    // 车位号
    NSString *_carNo;   // 车牌号
    NSString *_parkTime;   // 停车时间
    NSString *_carType;   // 车类型
    NSString *_carUser;   // 车用户
    NSString *_phoneNum;   // 联系电话
    
    BOOL _isShowMenu;
    SeatStatusModel *_seatStatusModel;
    
    YQSearchBar *searchBar;
    
    // 记录上次搜索车位数据
    DownParkMdel *_searchDownParkMdel;
}

@property (nonatomic,strong) YQSecondHeaderView *headerView;
@property (nonatomic,strong) MsgView *msgBgView;
@end

@implementation UndergGarageViewController

-(YQSecondHeaderView *)headerView
{
    if (_headerView == nil) {
        _headerView = [[YQSecondHeaderView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 85)];
        _headerView.backgroundColor = [UIColor colorWithHexString:@"1B82D1"];   
    }
    return _headerView;
}

-(UIImageView *)msgBgView
{
    if (_msgBgView == nil) {
        _msgBgView = [[MsgView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 55)];
        _msgBgView.backgroundColor = [UIColor colorWithHexString:@"#1A82D1"];
//        _msgBgView.image = [UIImage imageNamed:@"wifi_data_bg"];
        _msgBgView.leftLab.text = @"已占";
        _msgBgView.centerLab.text = @"剩余";
        _msgBgView.num = 2;
    }
    return _msgBgView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _parkData = @[].mutableCopy;
    _graphData = @[].mutableCopy;
    
    _menuTitle = @"停车信息";
    
    [self _initView];
    
    [self _initPointMapView];
    
    [self _initData];
}

-(void)_initView
{
    self.view.backgroundColor = [UIColor brownColor];
//    [self.view addSubview:self.headerView];
    
    // 创建点击菜单视图
    _showMenuView = [[ShowMenuView alloc] init];
    _showMenuView.hidden = YES;
    _showMenuView.menuDelegate = self;
    [[UIApplication sharedApplication].delegate.window addSubview:_showMenuView];
    
    [self.view addSubview:self.msgBgView];
    
    searchBar = [[YQSearchBar alloc] initWithFrame:CGRectMake(0, _msgBgView.bottom, KScreenWidth, 44)];
    searchBar.placeholder = @"请输入车牌号或车位号";
    searchBar.delegate = self;
    [searchBar setImage:[UIImage imageNamed:@"park_search_icon_blue"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    searchBar.bgImage = [UIImage imageWithColor:[UIColor whiteColor]];
    searchBar.labelColor = [UIColor colorWithHexString:@"#1A82D1"];
    [self.view addSubview:searchBar];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, searchBar.bottom - 0.8, KScreenWidth, 0.8)];
    lineView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.8];
    [self.view addSubview:lineView];
}

-(void)_initPointMapView
{
    indoorView = [[YQInDoorPointMapView alloc]initWithIndoorMapImageName:@"dxck" Frame:CGRectMake(0, searchBar.bottom, self.view.frame.size.width, KScreenHeight-64-searchBar.bottom)];
    indoorView.selInMapDelegate = self;
    [self.view addSubview:indoorView];
    
    [self.view insertSubview:indoorView.smallMapView aboveSubview:indoorView];
    indoorView.isMinScaleWithHeight = YES;
    
    UITapGestureRecognizer *endEditTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewEndEditing)];
    [indoorView addGestureRecognizer:endEditTap];
}
- (void)viewEndEditing {
    [self.view endEditing:YES];
}

-(void)_initData
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/seatCamera/AllSeat",ParkMain_Url];
    
    NSMutableDictionary *params = @{}.mutableCopy;
    [params setObject:KAreaId forKey:@"areaId"];
    [params setObject:@"1" forKey:@"seatIdle"];
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        if([responseObject[@"success"] boolValue]){
            
            NSArray *arr = responseObject[@"data"];
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                DownParkMdel *downParkMdel = [[DownParkMdel alloc] initWithDataDic:obj];
                // 过滤未停车位
                if([downParkMdel.seatIdle isEqualToString:@"1"]){
                    [_graphData addObject:downParkMdel.seatXY];
                    [_parkData addObject:downParkMdel];
                }
            }];
            
            indoorView.isLayCoord = YES;
            indoorView.graphData = _graphData;
            indoorView.parkDownArr = _parkData;
            
            _msgBgView.leftNumLab.text = [NSString stringWithFormat:@"%ld", _parkData.count];
            _msgBgView.centerNumLab.text = [NSString stringWithFormat:@"%ld", 208 - _parkData.count];
        }
        
    } failure:^(NSError *error) {
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark MenuControlDelegate
- (CGFloat)menuHeightInView:(NSInteger)index {
    if(index == 5){
        return 160;
    }else {
        return 40;
    }
}

- (NSInteger)menuNumInView {
    return 6;
}

- (NSString *)menuTitle:(NSInteger)index {
    switch (index) {
        case 0:
            return @"车位号";
            break;
        case 1:
            return @"车牌";
            break;
        case 2:
            return @"停车时间";
            break;
        case 3:
            return @"联系人";
            break;
        case 4:
            return @"联系电话";
            break;
        case 5:
            return @"停车图片";
            break;
            
        default:
            return @"";
            break;
    }
}

- (NSString *)menuTitleViewText {
    return _menuTitle;
}

- (NSString *)menuMessage:(NSInteger)index {
    switch (index) {
        case 0:
            return _carLocationNum;
            break;
        case 1:
            return _carNo;
            break;
        case 2:
            return _parkTime;
            break;
        case 3:
            return _carUser;
            break;
        case 4:
            return _phoneNum;
            break;
            
        default:
            return @"";
            break;
    }
}

- (ShowMenuStyle)menuViewStyle:(NSInteger)index {
    if(index == 5){
        return ImgConMenu;
    }else {
        return DefaultConMenu;
    }
}

- (NSString *)imageName:(NSInteger)index {
    if(index == 5){
        return _seatStatusModel.seatUrl;
    }else {
        return @"";
    }
}

- (void)didSelectMenu:(NSInteger)index {
    if(index == 5){
#pragma mark 查看图片
        _isShowMenu = YES;
        ImgBrowerViewController *imgBroVC = [[ImgBrowerViewController alloc] init];
        imgBroVC.imgUrlStr = _seatStatusModel.seatUrl;
        [self presentViewController:imgBroVC animated:YES completion:nil];
    }
}

#pragma mark searchBar delegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
    
    // 清除上次记录
    _carLocationNum = @"";
    _carNo = @"";
    _parkTime = @"";
    _carUser = @"";
    _phoneNum = @"";
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/seatCamera/findseat",ParkMain_Url];
    
    NSMutableDictionary *params = @{}.mutableCopy;
    [params setObject:searchBar.text forKey:@"search"];
    [params setObject:KAreaId forKey:@"areaId"];
    
    [self showHudInView:self.view hint:@""];
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        if([responseObject[@"success"] boolValue]){
            NSDictionary *data = responseObject[@"data"];
            if(data[@"seatStatus"] != nil && ![data[@"seatStatus"] isKindOfClass:[NSNull class]]){
                SeatStatusModel *seatStatusModel = [[SeatStatusModel alloc] initWithDataDic:data[@"seatStatus"]];
                _seatStatusModel = seatStatusModel;
                
                _carLocationNum = seatStatusModel.seatNo;
                _carNo = seatStatusModel.seatIdleCarno;
                _parkTime = seatStatusModel.seatOccutimeView;
                
                if(seatStatusModel.seatXY != nil && ![seatStatusModel.seatXY isKindOfClass:[NSNull class]]){
                    NSArray *pointAry = [seatStatusModel.seatXY componentsSeparatedByString:@","];
                    if(pointAry != nil && pointAry.count >= 2){
                        NSString *pointX = pointAry.firstObject;
                        NSString *pointY = pointAry.lastObject;
                        [self mapToPoint:CGPointMake(pointX.floatValue, pointY.floatValue)];
                    }
                }
                
                // 更改搜索到车位图标
                [_parkData enumerateObjectsUsingBlock:^(DownParkMdel *downParkMdel, NSUInteger idx, BOOL * _Nonnull stop) {
                    if([downParkMdel.seatNo isEqualToString:seatStatusModel.seatNo]){
                        if(_searchDownParkMdel != nil){
                            [indoorView normalCarIcon:_searchDownParkMdel withIndex:[_parkData indexOfObject:_searchDownParkMdel]];
                        }
                        [indoorView updateCarIcon:downParkMdel withIndex:idx];
                        _searchDownParkMdel = downParkMdel;
                        *stop = YES;
                    }
                }];
                
            }
            if(data[@"card"] != nil && ![data[@"card"] isKindOfClass:[NSNull class]]){
                ParkCardModel *parkCardModel = [[ParkCardModel alloc] initWithDataDic:data[@"card"]];
                _carUser = parkCardModel.cardName;
                _phoneNum = parkCardModel.cardPhone;
            }else {
                _carUser = @"";
                _phoneNum = @"";
            }
            
            _showMenuView.hidden = NO;
            [_showMenuView reloadMenuData];
            
            
        }else {
            [self showHint:responseObject[@"message"]];
        }
        
    } failure:^(NSError *error) {
        [self hideHud];
        [self showHint:KRequestFailMsg];
    }];
}

- (void)mapToPoint:(CGPoint)point {
    // 地图滑动到搜索位置
    CGFloat difWidth = indoorView.width;
    CGFloat difHeight = indoorView.height;
    if(indoorView.mapView.width < difWidth){
        difWidth = indoorView.mapView.width;
    }
    if(indoorView.mapView.height < difHeight){
        difHeight = indoorView.mapView.height;
    }
    
    difWidth = 0;
    difHeight = 0;
    CGPoint mapPoint = CGPointMake(indoorView.contentSize.width/indoorView.mapView.image.size.width * point.x - difWidth, indoorView.contentSize.height/indoorView.mapView.image.size.height * point.y - difHeight);
    
    [indoorView setContentOffset:mapPoint animated:YES];
}

#pragma mark 点击点位图图标
- (void)selInMapWithId:(NSString *)identity {
    _showMenuView.hidden = NO;
    
    // 清除上次记录
    _carLocationNum = @"";
    _carNo = @"";
    _parkTime = @"";
    _carUser = @"";
    _phoneNum = @"";
    
    [self.view endEditing:YES];
    
    NSInteger selectIndex = [identity integerValue]-100;
    if(_parkData.count <= selectIndex){
        return;
    }
    DownParkMdel *model = _parkData[selectIndex];
    
    if(_searchDownParkMdel != nil){
        // 去除搜索标记图标
        [indoorView normalCarIcon:_searchDownParkMdel withIndex:[_parkData indexOfObject:_searchDownParkMdel]];
    }
    [indoorView updateCarIcon:model withIndex:[_parkData indexOfObject:model]];
    _searchDownParkMdel = model;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/seatCamera/findBySeat", ParkMain_Url];
    NSMutableDictionary *param = @{}.mutableCopy;
    [param setObject:model.seatNo forKey:@"seatcode"];
    [param setObject:KAreaId forKey:@"areaId"];
    [self showHudInView:self.view hint:@""];
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        if([responseObject[@"success"] boolValue]){
            NSDictionary *data = responseObject[@"data"];
            if(data == nil || [data isKindOfClass:[NSNull class]]){
                [self showHint:@"无数据"];
                return ;
            }
            if(data[@"seatStatus"] != nil && ![data[@"seatStatus"] isKindOfClass:[NSNull class]]){
                SeatStatusModel *seatStatusModel = [[SeatStatusModel alloc] initWithDataDic:data[@"seatStatus"]];
                _seatStatusModel = seatStatusModel;
                
                _carLocationNum = seatStatusModel.seatNo;
                _carNo = seatStatusModel.seatIdleCarno;
                _parkTime = seatStatusModel.seatOccutimeView;
                
            }
            if(data[@"card"] != nil && ![data[@"card"] isKindOfClass:[NSNull class]]){
                ParkCardModel *parkCardModel = [[ParkCardModel alloc] initWithDataDic:data[@"card"]];
                _carUser = parkCardModel.cardName;
                _phoneNum = parkCardModel.cardPhone;
            }else {
                _carUser = @"";
                _phoneNum = @"";
            }
            
            [_showMenuView reloadMenuData];
        }
    } failure:^(NSError *error) {
        [self hideHud];
    }];
    
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if(_isShowMenu){
        _showMenuView.alpha = 0;
        _showMenuView.hidden = NO;
        [UIView animateWithDuration:0.1 animations:^{
            _showMenuView.alpha = 1;
        }];
        _isShowMenu = NO;
    }
}
*/
 
@end
