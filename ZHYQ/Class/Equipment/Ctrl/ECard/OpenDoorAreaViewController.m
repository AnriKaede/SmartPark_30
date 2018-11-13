//
//  OpenDoorAreaViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/20.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "OpenDoorAreaViewController.h"

#import "OpenDoorAreaCltViewCell.h"
#import "OpenDoorAreaheaderView.h"

#import "OpenDoorModel.h"

@interface OpenDoorAreaViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    NSMutableArray *_dataArr;
}
@property (nonatomic,strong) NSMutableArray *selectArr;

@end

@implementation OpenDoorAreaViewController

-(NSMutableArray *)selectArr
{
    if (_selectArr == nil) {
        _selectArr = [NSMutableArray array];
    }
    return _selectArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArr = @[].mutableCopy;
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    
    [self _initView];
    
    [self _loadData];
}

-(void)_initView {
    [self initNavItems];
    
    [self _initCollectionView];
}

-(void)initNavItems
{
    self.title = @"开门区域";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}

-(void)_leftBarBtnItemClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)_rightBarBtnItemClick:(id)sender
{
    for (int i = 0; i < _selectArr.count; i++) {
        NSIndexPath *path = _selectArr[i];
        DLog(@"%ld,%ld",path.section,path.row);
    }
}

-(void)_initCollectionView
{
    //1.初始化layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    //设置collectionView滚动方向
    //    [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    //设置headerView的尺寸大小
    layout.headerReferenceSize = CGSizeMake(self.view.frame.size.width, 20);
    //该方法也可以设置itemSize
    
    layout.itemSize = CGSizeMake(110, 60);
    
    //2.初始化collectionView
    //    mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    [self.collectionView setCollectionViewLayout:layout];
    if (kDevice_Is_iPhoneX) {
        self.collectionView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight - 88-34);
    }else{
        self.collectionView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64);
    }
    [self.view addSubview:self.collectionView];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.mj_header.hidden = YES;
    self.collectionView.mj_footer.hidden = YES;
    
    //3.注册collectionViewCell
    //注意，此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致 均为 cellId
    [self.collectionView registerNib:[UINib nibWithNibName:@"OpenDoorAreaCltViewCell" bundle:nil] forCellWithReuseIdentifier:@"OpenDoorAreaCltViewCell"];
    
    //注册headerView  此处的ReuseIdentifier 必须和 cellForItemAtIndexPath 方法中 一致  均为reusableView
    [self.collectionView registerClass:[OpenDoorAreaheaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"OpenDoorAreaheaderView"];
    
    //4.设置代理
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.collectionView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
}

-(void)_loadData
{
    NSString *urlStr = [NSString stringWithFormat:@"%@/visitor/getOpenOwnDoorAuth", Main_Url];
    
    NSMutableDictionary *params = @{}.mutableCopy;
    [params setObject:_basePerNo forKey:@"certIds"];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        [_dataArr removeAllObjects];
        [self hideHud];
        [self.tableView.mj_header endRefreshing];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *dic = responseObject[@"responseData"];
            NSArray *arr = dic[@"AuthList"];
            
            NSMutableArray *layerIDarr = @[].mutableCopy;
            NSMutableArray *tempDataArr = @[].mutableCopy;
            
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                OpenDoorModel *model = [[OpenDoorModel alloc] initWithDataDic:obj];
                if(model.LAYER_ID != nil && ![model.LAYER_ID isKindOfClass:[NSNull class]]){
                    [layerIDarr addObject:model.LAYER_ID];
                    [tempDataArr addObject:model];
                }
            }];
            
            // 直接调用集合是类初始化方法。
            NSSet *set = [NSSet setWithArray:layerIDarr];
            NSArray *layerIdArr = [set allObjects];
            
            NSArray *result = [layerIdArr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                return [obj1 compare:obj2]; //升序
            }];
            
            [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSNumber *layerId = (NSNumber *)obj;
                NSMutableArray *layerArr = @[].mutableCopy;
                [tempDataArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    OpenDoorModel *model = (OpenDoorModel *)obj;
                    if ([[layerId stringValue] isEqualToString:[NSString stringWithFormat:@"%@",model.LAYER_ID]]) {
                        [layerArr addObject:model];
                    }
                }];
                
                [_dataArr addObject:layerArr];
            }];
            
            [self.collectionView reloadData];
        }
    } failure:^(NSError *error) {
        //        DLog(@"%@",error);
        [self hideHud];
        [self.tableView.mj_header endRefreshing];
    }];
}

#pragma mark UICollectionView协议
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _dataArr.count;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *arr = _dataArr[section];
    return arr.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    OpenDoorAreaCltViewCell *cell = (OpenDoorAreaCltViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"OpenDoorAreaCltViewCell" forIndexPath:indexPath];
    
    NSArray *arr = _dataArr[indexPath.section];
    cell.openDoorModel = arr[indexPath.row];
    
    return cell;
}

//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(KScreenWidth, 44);
}

//footer的size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake(10, 0);
}

//header的size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(KScreenWidth, 40);
}

//设置每个item的UIEdgeInsets
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0.0, 10.0*wScale, 0.0, 10.0*wScale);
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0*wScale;
}

//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0*wScale;
}

//通过设置SupplementaryViewOfKind 来设置头部或者底部的view，其中 ReuseIdentifier 的值必须和 注册是填写的一致，本例都为 “reusableView”
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    OpenDoorAreaheaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"OpenDoorAreaheaderView" forIndexPath:indexPath];
    
    NSArray *arr = _dataArr[indexPath.section];
    OpenDoorModel *model = arr[0];
    NSString *celStr = [NSString stringWithFormat:@"%@",model.LAYER_NAME];
    
    headerView.titleLab.text = celStr;
    return headerView;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    DLog(@"%ld",indexPath.row);
    OpenDoorAreaCltViewCell *cell = (OpenDoorAreaCltViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    cell.areaName.selected = !cell.areaName.selected;
    
    __block BOOL isExist = NO;

    if (cell.areaName.selected) {
        [self.selectArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSIndexPath *path = (NSIndexPath *)obj;
            if (indexPath == path) {
                *stop = YES;
                isExist = YES;
            }
        }];
        if (!isExist) {
            [self.selectArr addObject:indexPath];
        }
        
    }else
    {
        [self.selectArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSIndexPath *path = (NSIndexPath *)obj;
            if (indexPath == path) {
                *stop = YES;
                isExist = YES;
            }
        }];
        if (isExist) {
            [self.selectArr removeObject:indexPath];
        }
    }
     */
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
