//
//  EquipmentViewCtroller.m
//  ZHYQ
//
//  Created by 焦平 on 2017/10/30.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "EquipmentViewCtroller.h"
#import "EquipmentCollectionViewCell.h"

#import "EquipmentHeaderView.h"
#import "EquipmentScedheaderView.h"

#import "FirstMenuModel.h"

//#import "WifiCenterViewController.h"
#import "WifiGroupViewController.h"
//#import "StreetLightsViewController.h"
#import "StreetLigGroupViewController.h"
#import "StreetMapViewController.h"
#import "ManholeCoverViewController.h"
//#import "WaterViewController.h"
#import "WaterConViewController.h"
#import "FountainViewController.h"
//#import "BgMusicViewController.h"
#import "MusicGroupViewController.h"
#import "ParkingViewController.h"
//#import "AirViewController.h"
#import "DistributorViewController.h"
//#import "AirConditionViewController.h"
#import "AirCondGroupViewController.h"
#import "ElevatorViewController.h"

//#import "LEDViewController.h"
#import "LEDMapViewController.h"
#import "ParkNightViewController.h"
//#import "MeetRoomCenterViewController.h"
//#import "MeetPageViewController.h"
#import "MeetRoomGroupViewController.h"
#import "DrainWaterViewController.h"
#import "EnergyConViewController.h"
//#import "EntranceGuardViewController.h"
#import "DoorGroupViewController.h"
#import "ECardViewController.h"
#import "MsgPostViewController.h"
//#import "MonitorCenterViewController.h"
#import "MonitorGroupViewController.h"
#import "VisitorTabbarController.h"
#import "VisotorListViewController.h"
#import "FoodViewController.h"
#import "TrainViewController.h"
#import "LightViewController.h"
#import "SmartDistributorViewController.h"
#import "CommunicationViewController.h"

#import "HpDoorCenViewController.h"

#import "MealCenViewController.h"

#import "BgMusicCenterViewController.h"
#import "SelFaceViewController.h"

//#import "WarnTabbarController.h"
#import "WarnTodayViewController.h"

#import "RepairsCenViewController.h"

#import "LightLockWebViewController.h"

#import "HotelViewController.h"

#import "ParentMenuModel.h"
#import "MenuModel.h"
#import "TopMenuModel.h"
#import "FloorModel.h"
#import "NoDataView.h"

#import "LoginViewController.h"

#import "MonitorLoginInfoModel.h"

#import "InDoorWifiViewController.h"

#define equipmentCellID    @"EquipmentCollectionViewCell"
#define headViewOne        @"headViewOne"
#define headViewSeconed    @"headViewSeconed"

@interface EquipmentViewCtroller()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,equipmentClickDelegate,reloadDelegate>
{
//    UICollectionView *mainCollectionView;
    EquipmentHeaderView *headerView1;
    ParentMenuModel *_headerParentMenuModel;
    NoDataView *nodataView;
}

//@property (nonatomic,strong) NSMutableArray *imageDataArr;
//@property (nonatomic,strong) NSMutableArray *titleDataArr;
@property (nonatomic,strong) NSMutableArray *sectionTitleArr;
@property (nonatomic,strong) NSMutableArray *menuArr;

@end

@implementation EquipmentViewCtroller

-(NSMutableArray *)menuArr
{
    if (_menuArr == nil) {
        _menuArr = [NSMutableArray array];
    }
    return _menuArr;
}

/*
-(NSMutableArray *)imageDataArr
{
    if (_imageDataArr == nil) {
        _imageDataArr = [NSMutableArray array];
    }
    return _imageDataArr;
}

-(NSMutableArray *)titleDataArr
{
    if (_titleDataArr == nil) {
        _titleDataArr = [NSMutableArray array];
    }
    return _titleDataArr;
}
 */

-(NSMutableArray *)sectionTitleArr
{
    if (_sectionTitleArr == nil) {
        _sectionTitleArr = [NSMutableArray array];
    }
    return _sectionTitleArr;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [kNotificationCenter addObserver:self selector:@selector(_initData) name:@"loginNotification" object:nil];
    
    [kNotificationCenter addObserver:self selector:@selector(loginOutAction) name:@"loginOutNotification" object:nil];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self _initView];
    /*
    if ([kUserDefaults boolForKey:KLoginState]) {
        [self _initData];
    }
    */
}

-(void)tabbarClick
{
    if ([kUserDefaults objectForKey:KLoginState]) {
        [self _initData];
    }else{
        [self.menuArr removeAllObjects];
        [self.collectionView reloadData];
        RootNavigationController *loginVC = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginNavViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
    }
}

-(void)loginOutAction
{
    [_menuArr removeAllObjects];
    [self.collectionView reloadData];
}

-(void)_initView
{
    [self _initCollectionView];
}

-(void)_initCollectionView
{
    //1.初始化layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //设置collectionView滚动方向
    //    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    //设置headerView的尺寸大小
    layout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 100);
    //该方法也可以设置itemSize
    
    layout.itemSize = CGSizeMake(110, 60);
    
    //2.初始化collectionView
//    mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.collectionView setCollectionViewLayout:layout];
    if (kDevice_Is_iPhoneX) {
        self.collectionView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight - 88 - 83);
    }else
    {
        self.collectionView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64 - 48);
    }
    
    //4.设置代理
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.bounces = NO;
    self.collectionView.mj_header.hidden = YES;
    self.collectionView.mj_footer.hidden = YES;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.enablePlaceHolderView = YES;
    nodataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 5, KScreenWidth, KScreenHeight-64-49)];
    nodataView.label.text = @"点击加载";
    nodataView.delegate = self;
    
    self.collectionView.yh_PlaceHolderView = nodataView;
    self.collectionView.yh_PlaceHolderView.hidden = YES;
    nodataView.hidden = YES;
    
    //3.注册collectionViewCell
    //注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
    [self.collectionView registerClass:[EquipmentCollectionViewCell class] forCellWithReuseIdentifier:equipmentCellID];
    
    //注册headerView  此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致  均为reusableView
    [self.collectionView registerClass:[EquipmentHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headViewOne];
    [self.collectionView registerClass:[EquipmentScedheaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headViewSeconed];
    [self.view addSubview:self.collectionView];
    
    // 监听网络变化
    [self monitorNetwork];
}

#pragma mark 监听网络变化
- (void)monitorNetwork {
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                //                NSLog(@"未识别的网络");
                nodataView.imgView.image = [UIImage imageNamed:@"customvoice_networkerror"];
                nodataView.label.text = @"对不起,网络连接失败";
                self.collectionView.yh_PlaceHolderView.hidden = NO;
                nodataView.hidden = NO;
                // 发送无网络通知
                [[NSNotificationCenter defaultCenter] postNotificationName:@"NotNetworkNotification" object:nil];
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                //                NSLog(@"不可达的网络(未连接)");
                nodataView.imgView.image = [UIImage imageNamed:@"customvoice_networkerror"];
                nodataView.label.text = @"对不起,网络连接失败";
                self.collectionView.yh_PlaceHolderView.hidden = NO;
                nodataView.hidden = NO;
                // 发送无网络通知
                [[NSNotificationCenter defaultCenter] postNotificationName:@"NotNetworkNotification" object:nil];
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                //                NSLog(@"2G,3G,4G...的网络");
                if(self.sectionTitleArr == nil || self.sectionTitleArr.count <= 0){
                    if ([kUserDefaults objectForKey:KLoginState]) {
                        [self _initData];
                    }
                }
                // 发送恢复网络通知
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ResumeNetworkNotification" object:nil];
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                //                NSLog(@"wifi的网络");
                if(self.sectionTitleArr == nil || self.sectionTitleArr.count <= 0){
                    if ([kUserDefaults objectForKey:KLoginState]) {
                        [self _initData];
                    }
                }
                // 发送恢复网络通知
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ResumeNetworkNotification" object:nil];
                break;
            
            default:
                break;
        }
    }];
    
    [manager startMonitoring];
}

-(void)_initData
{
    [self _loadFunctionListData];
}

-(void)_loadFunctionListData
{
    [self showHudInView:self.view hint:@""];
    
    NSString *str = [kUserDefaults objectForKey:KLoginUserName];
    
    NSMutableArray *parentIdArr = [NSMutableArray array];

    NSString *urlStr = [NSString stringWithFormat:@"%@/public/getParentMenuList?loginName=%@&menuType=2",Main_Url,str];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            [self hideHud];
            self.collectionView.yh_PlaceHolderView.hidden = NO;
            nodataView.hidden = NO;
            
            NSArray *arr = responseObject[@"responseData"];
            if (self.sectionTitleArr.count != 0) {
                [self.sectionTitleArr removeAllObjects];
            }
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FirstMenuModel *model = [[FirstMenuModel alloc] initWithDataDic:obj];
                // 剔除menuID为0的组(顶部其他)
                if (model.MENU_ID != nil && ![model.MENU_ID isKindOfClass:[NSNull class]] && model.MENU_ID.integerValue != 0) {
                    [self.sectionTitleArr addObject:model.MENU_NAME];
                }
                [parentIdArr addObject:model.MENU_ID];
            }];
            [self _loadChildMenuData:[parentIdArr componentsJoinedByString:@","]];
        }
    } failure:^(NSError *error) {
        [self hideHud];
        self.collectionView.yh_PlaceHolderView.hidden = NO;
        nodataView.hidden = NO;
//        NSLog(@"%@",error);
    }];
}

-(void)_loadChildMenuData:(NSString *)parentIDs
{

    NSString *str = [kUserDefaults objectForKey:KLoginUserName];
    NSString *urlStr = [NSString stringWithFormat:@"%@/public/getChildMenuList?loginName=%@&menuType=2&parentMenuId=%@",Main_Url,str,parentIDs];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
    
            NSArray *arr = responseObject[@"responseData"];
            
            [self.menuArr removeAllObjects];
            _headerParentMenuModel = nil;
            
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                ParentMenuModel *parentMenuModel = [[ParentMenuModel alloc] initWithDataDic:obj];
                // 剔除menuID为0的组(顶部其他)
                if ([parentMenuModel.parentMenuId isEqualToString:@"0"]) {
                    _headerParentMenuModel = parentMenuModel;
                }else {
                    [self.menuArr addObject:parentMenuModel];
                }
            }];
        }

        [self.collectionView reloadData];
    } failure:^(NSError *error) {
        DLog(@"%@",error);
    }];
}

#pragma mark collectionView代理方法
//返回section个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.menuArr.count;
}

//每个section的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    ParentMenuModel *model = self.menuArr[section];
    return model.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EquipmentCollectionViewCell *cell = (EquipmentCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:equipmentCellID forIndexPath:indexPath];
    
    ParentMenuModel *model = self.menuArr[indexPath.section];
    MenuModel *menuModel = model.items[indexPath.row];
    
    NSString *imageName = menuModel.MENU_ICON;

    if (imageName != nil && ![imageName isKindOfClass:[NSNull class]]) {
        cell.topImageView.image = [UIImage imageNamed:imageName];
    }
    
    
    cell.titleLab.text = menuModel.MENU_NAME;
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake((KScreenWidth-65*wScale)/4, 60);
}

//footer的size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(10, 0);
}

//header的size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGSize size;
    if (section == 0 && _headerParentMenuModel != nil) {
        size = CGSizeMake(10, 150.0);
    }else{
        size = CGSizeMake(10, 35);
    }
    return size;
}

//设置每个item的UIEdgeInsets
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10.0, 10.0*wScale, 10.0, 10.0*wScale);
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 15.0*wScale;
}


//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0*wScale;
}

//通过设置SupplementaryViewOfKind 来设置头部或者底部的view，其中 ReuseIdentifier 的值必须和 注册是填写的一致，本例都为 “reusableView”
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *headerView;
    if (indexPath.section == 0 && _headerParentMenuModel != nil) {
        headerView1 = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headViewOne forIndexPath:indexPath];
        headerView1.delegate = self;
        headerView1.parentMenuModel = _headerParentMenuModel;
        headerView1.subTitle = self.sectionTitleArr[indexPath.section];
        headerView1.backgroundColor = CNavBgColor;
        headerView = headerView1;
    }else
    {
        EquipmentScedheaderView *headerView2 = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headViewSeconed forIndexPath:indexPath];
        headerView2.titleLab.text = [NSString stringWithFormat:@"%@",self.sectionTitleArr[indexPath.section]];
        headerView2.backgroundColor = [UIColor clearColor];
        headerView = headerView2;
    }
    
    return headerView;
}

//点击item方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.section == 0) {
        ParentMenuModel *parentMenuModel = self.menuArr[indexPath.section];
        MenuModel *model = parentMenuModel.items[indexPath.row];
        
        switch ([model.MENU_ID integerValue]) {
            case 8:
                {

                    WifiGroupViewController *VC = [[WifiGroupViewController alloc] init];
                    VC.menuID = [NSString stringWithFormat:@"%@",model.MENU_ID];
                    VC.title = model.MENU_NAME;
                    [self.navigationController pushViewController:VC animated:YES];
                    
                }
                break;
            case 9:
                {
//                    StreetLigGroupViewController *streetLigVC = [[StreetLigGroupViewController alloc] init];
//                    streetLigVC.title = model.MENU_NAME;
//                    [self.navigationController pushViewController:streetLigVC animated:YES];
                    StreetMapViewController *streetMapVC = [[StreetMapViewController alloc] init];
                    streetMapVC.title = model.MENU_NAME;
                    [self.navigationController pushViewController:streetMapVC animated:YES];
                }
                break;
            case 10:
                {
                    /*
                    ManholeCoverViewController *mholeCoverVC = [[ManholeCoverViewController alloc] init];
                    mholeCoverVC.title = model.MENU_NAME;
                    [self.navigationController pushViewController:mholeCoverVC animated:YES];
                     */
                    
                    CommunicationViewController *commncVC = [[CommunicationViewController alloc] init];
                    commncVC.title = model.MENU_NAME;
                    [self.navigationController pushViewController:commncVC animated:YES];
                    break;
                }
                break;
            case 11:
                {
                    WaterConViewController*waterVC = [[WaterConViewController alloc] init];
                    waterVC.title = model.MENU_NAME;
                    [self.navigationController pushViewController:waterVC animated:YES];
                }
                break;
            case 12:
                {
                    FountainViewController *fountainVC = [[FountainViewController alloc] init];
                    fountainVC.title = model.MENU_NAME;
                    [self.navigationController pushViewController:fountainVC animated:YES];
                }
                break;
            case 13:
                {
                    MusicGroupViewController *musicVC = [[MusicGroupViewController alloc] init];
                    musicVC.menuID = [NSString stringWithFormat:@"%@",model.MENU_ID];
                    musicVC.title = model.MENU_NAME;
                    [self.navigationController pushViewController:musicVC animated:YES];
                    
                }
                break;
            case 14:
                {
                    ParkingViewController *parkVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"ParkingViewController"];
                    parkVC.title = model.MENU_NAME;
                    [self.navigationController pushViewController:parkVC animated:YES];
                }
                break;
            case 15:
                {
                    // 车库照明
                    ParkNightViewController *parkNightVC = [[ParkNightViewController alloc] init];
                    parkNightVC.title = model.MENU_NAME;
                    [self.navigationController pushViewController:parkNightVC animated:YES];
                }
                break;
            case 150:
            {
                // 光交锁
                /*
                LightLockWebViewController *lightLockVC = [[LightLockWebViewController alloc] init];
                lightLockVC.title = model.MENU_NAME;
                lightLockVC.isHidenNaviBar = YES;
                [self.navigationController pushViewController:lightLockVC animated:YES];
                 */
                CommunicationViewController *commncVC = [[CommunicationViewController alloc] init];
                commncVC.title = model.MENU_NAME;
                [self.navigationController pushViewController:commncVC animated:YES];
                break;
            }
            
            case 16:
                {
                    ElevatorViewController *elecatorVC = [[ElevatorViewController alloc] init];
                    elecatorVC.title = model.MENU_NAME;
                    [self.navigationController pushViewController:elecatorVC animated:YES];
                }
                break;
            case 17:
                {
                    // 低压配电
                    DistributorViewController *disVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"DistributorViewController"];
                    disVC.title = model.MENU_NAME;
                    [self.navigationController pushViewController:disVC animated:YES];
                }
                break;
            case 18:
                {
                    AirCondGroupViewController *airConditionVC = [[AirCondGroupViewController alloc] init];
                    airConditionVC.menuID = [NSString stringWithFormat:@"%@",model.MENU_ID];
                    airConditionVC.title = model.MENU_NAME;
                    [self.navigationController pushViewController:airConditionVC animated:YES];
                }
                break;
            case 19:
                {
                    LEDMapViewController *ledVC = [[LEDMapViewController alloc] init];
                    ledVC.title = model.MENU_NAME;
                    [self.navigationController pushViewController:ledVC animated:YES];
                }
                break;
            case 20:
                {
                    // 会议室
                    MeetRoomGroupViewController *meetGroupVC = [[MeetRoomGroupViewController alloc] init];
                    meetGroupVC.title = model.MENU_NAME;
                    [self.navigationController pushViewController:meetGroupVC animated:YES];
                }
                break;
                
            case 60322:
                {
                    // 给排水
                    DrainWaterViewController *drainWaterVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"DrainWaterViewController"];
                    drainWaterVC.title = model.MENU_NAME;
                    [self.navigationController pushViewController:drainWaterVC animated:YES];
                    break;
                }
                
            case 22:
                {
                    //恒压供水
                    DrainWaterViewController *drainWaterVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"DrainWaterViewController"];
                    drainWaterVC.title = model.MENU_NAME;
                    [self.navigationController pushViewController:drainWaterVC animated:YES];
                }
                break;
            case 23:
                {
                    // 能耗
                    EnergyConViewController *energyConVC = [[EnergyConViewController alloc] init];
                    energyConVC.title = model.MENU_NAME;
                    [self.navigationController pushViewController:energyConVC animated:YES];
                }
                break;
            case 200:
            {
                // 智能照明
                LightViewController *lightVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"LightViewController"];
                lightVC.title = model.MENU_NAME;
                [self.navigationController pushViewController:lightVC animated:YES];
                break;
            }
            
            // 人脸轨迹
            case 21:
            {
                SelFaceViewController *faceVC = [[SelFaceViewController alloc] init];
                faceVC.title = model.MENU_NAME;
                [self.navigationController pushViewController:faceVC animated:YES];
            }
                break;
                
            case 24:
                {
                    MonitorGroupViewController *monitorVC = [[MonitorGroupViewController alloc] init];
                    monitorVC.menuID = [NSString stringWithFormat:@"%@",model.MENU_ID];
                    monitorVC.title = model.MENU_NAME;
                    [self.navigationController pushViewController:monitorVC animated:YES];
                    
                }
                break;
            case 25:
                {
                    VisotorListViewController *visitorVC = [[VisotorListViewController alloc] init];
                    visitorVC.title = model.MENU_NAME;
                    [self.navigationController pushViewController:visitorVC animated:YES];
                }
                break;
            case 26:
                {
                    // 门禁
                    DoorGroupViewController *doorGroupVC = [[DoorGroupViewController alloc] init];
                    doorGroupVC.title = model.MENU_NAME;
                    doorGroupVC.menuID = [NSString stringWithFormat:@"%@",model.MENU_ID];
                    [self.navigationController pushViewController:doorGroupVC animated:YES];
                }
                break;
            case 27:
                {
                    // 一卡通
                    ECardViewController *eCardVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"ECardViewController"];
                    eCardVC.title = model.MENU_NAME;
                    [self.navigationController pushViewController:eCardVC animated:YES];
                    break;
                }

            case 28:
            {
                // 智慧餐饮
                FoodViewController *foodVC = [[FoodViewController alloc] init];
//                foodVC.isHidenNaviBar = YES;
                [self.navigationController pushViewController:foodVC animated:YES];
                break;
            }
                
            case 30:
            {
                // 智慧酒店
                HotelViewController *hotelVC = [[HotelViewController alloc] init];
                hotelVC.isHidenNaviBar = YES;
                [self.navigationController pushViewController:hotelVC animated:YES];
                
                break;
            }
                
            case 32:
            {
                // 智慧培训
                TrainViewController *trainVC = [[TrainViewController alloc] init];
                trainVC.isHidenNaviBar = YES;
                [self.navigationController pushViewController:trainVC animated:YES];
                break;
            }
                
            case 33:
            {
                // 智慧物业
                [self showHint:@"敬请期待"];
                break;
            }
            case 34:
            {
                // 取餐叫号
                MealCenViewController *mealVC = [[MealCenViewController alloc] init];
                [self.navigationController pushViewController:mealVC animated:YES];
                break;
            }
            case 123293:
            {
                // 智慧配电
                SmartDistributorViewController *distributorVC = [[SmartDistributorViewController alloc] init];
                distributorVC.isHidenNaviBar = YES;
                [self.navigationController pushViewController:distributorVC animated:YES];
                break;
            }
            case 35:
            {
                // 福门
                HpDoorCenViewController *hpVC = [[HpDoorCenViewController alloc] init];
                [self.navigationController pushViewController:hpVC animated:YES];
                break;
            }
                
            default:
                [self showHint:@"敬请期待"];
                break;
        }

}

#pragma mark -- equipmentClickDelegate

-(void)EquipmentBtnEvent:(equipmentEventType)type
{
    switch (type) {
        case equipmentEventFaulty:
            [self faultyEquipmentClick];
            break;
        case equipmentEventRepairOrderList:
            [self repairOrderClick];
            break;
        case equipmentEventInfomationPost:
            [self infomationPostClick];
            break;
        default:
            break;
    }
}

#pragma mark -- 故障设备

-(void)faultyEquipmentClick
{
//    DLog(@"faultyEquipmentClick");
//    [self showHint:@"敬请期待"];
    
    /*
    WarnTabbarController *warnTab = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"WarnTabbarController"];
    warnTab.title = @"设备故障";
    [self.navigationController pushViewController:warnTab animated:YES];
     */
    WarnTodayViewController *warnVC = [[WarnTodayViewController alloc] init];
    warnVC.title = @"设备故障";
    [self.navigationController pushViewController:warnVC animated:YES];
}

#pragma mark -- 维修派单
-(void)repairOrderClick
{
//    DLog(@"repairOrderClick");
//    [self showHint:@"敬请期待"];
    
    RepairsCenViewController *repairsVC = [[RepairsCenViewController alloc] init];
    repairsVC.title = @"维修派单";
    [self.navigationController pushViewController:repairsVC animated:YES];
}

#pragma mark -- 员工信息(原信息发布)
-(void)infomationPostClick
{
    /*
    DLog(@"infomationPostClick");
    MsgPostViewController *msgPostVC = [[MsgPostViewController alloc] init];
    [self.navigationController pushViewController:msgPostVC animated:YES];
    */
    
    // 一卡通
    ECardViewController *eCardVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"ECardViewController"];
    eCardVC.title = @"综合查询";
    [self.navigationController pushViewController:eCardVC animated:YES];
}

#pragma mark 无数据重新加载
-(void)reload
{
    if ([kUserDefaults boolForKey:KLoginState]) {
        [self _loadFunctionListData];
    }else{
        RootNavigationController *loginVC = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginNavViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
    }
}

-(void)dealloc
{
    [kNotificationCenter removeObserver:self name:@"loginNotification" object:nil];
    [kNotificationCenter removeObserver:self name:@"loginOutNotification" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
