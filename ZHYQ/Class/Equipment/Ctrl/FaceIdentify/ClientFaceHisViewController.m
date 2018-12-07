//
//  ClientFaceHisViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/29.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "ClientFaceHisViewController.h"
#import "FaceHistoryCell.h"

@interface ClientFaceHisViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_collectionView;
    NSMutableArray *_hisDatas;
    
    NSMutableArray *_historyTitleData;
    NSMutableArray *_historyData;
    UIView *_bottomView;
    BOOL _isDelete;
    
    UIButton *_rightBt;
    NoDataView *_noDataView;
    
    int _page;
    int _length;
}
@end

@implementation ClientFaceHisViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _hisDatas = @[].mutableCopy;
    _historyTitleData = @[].mutableCopy;
    _historyData = @[].mutableCopy;
    
    _page = 1;
    _length = 24;
    
    self.title = @"选择历史照片";
    
    [self _initView];
    [self _createBottomView];
    
    [self _loadHistoryData];
}

- (void)_initView {
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _rightBt = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightBt.frame = CGRectMake(0, 0, 50, 40);
    [_rightBt setTitle:@"删除" forState:UIControlStateNormal];
    [_rightBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _rightBt.titleLabel.font = [UIFont systemFontOfSize:15];
    [_rightBt addTarget:self action:@selector(rightAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightBt];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 1;
    layout.minimumLineSpacing = 1;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight) collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView registerNib:[UINib nibWithNibName:@"FaceHistoryCell" bundle:nil] forCellWithReuseIdentifier:@"FaceHistoryCell"];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"reusableView"];
    [self.view addSubview:_collectionView];
    
    layout.estimatedItemSize = CGSizeZero;
    
    _collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 1;
        [self _loadHistoryData];
    }];
    // 上拉刷新
    _collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _page ++;
        [self _loadHistoryData];
    }];
    _collectionView.mj_footer.hidden = YES;
    
    // 无数据视图
    _noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64-49)];
    _noDataView.hidden = YES;
    [self.view addSubview:_noDataView];
    
}
- (void)_createBottomView {
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, KScreenHeight - kTopHeight - 60, KScreenWidth, 60)];
    _bottomView.hidden = YES;
    _bottomView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:_bottomView];
    
    NSString *leftTitle = @"";
    leftTitle = @"取消";
    UIButton *bottomLeftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    bottomLeftButton.tag = 2001;
    bottomLeftButton.frame = CGRectMake(0, 0, KScreenWidth/2, _bottomView.height);
    [bottomLeftButton setBackgroundImage:[UIImage imageNamed:@"scene_all_close_bg"] forState:UIControlStateNormal];
    [bottomLeftButton setTitle:leftTitle forState:UIControlStateNormal];
    [bottomLeftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [bottomLeftButton addTarget:self action:@selector(bottomLeftAction) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:bottomLeftButton];
    
    NSString *rightTitle = @"";
    rightTitle = @"删除所选";
    UIButton *bottomRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    bottomRightButton.tag = 2002;
    bottomRightButton.frame = CGRectMake(KScreenWidth/2, 0, KScreenWidth/2, _bottomView.height);
    bottomRightButton.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
    [bottomRightButton setTitle:rightTitle forState:UIControlStateNormal];
    [bottomRightButton setTitleColor:[UIColor colorWithHexString:@"#CCFF00"] forState:UIControlStateNormal];
    [bottomRightButton addTarget:self action:@selector(bottomRightAction) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:bottomRightButton];
    
}
#pragma mark 导航栏按钮
-(void)_leftBarBtnItemClick:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)rightAction {
    if(_isDelete){
        _rightBt.selected = !_rightBt.selected;
        // 全选
        [_historyData enumerateObjectsUsingBlock:^(NSArray *monthModels, NSUInteger idx, BOOL * _Nonnull stop) {
            [monthModels enumerateObjectsUsingBlock:^(FaceHistoryModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
                model.isSelDelete = _rightBt.selected;
            }];
        }];
        [self reloadColletionView];
    }else {
        // 删除
        _isDelete = YES;
        [self reloadColletionView];
        _bottomView.hidden = NO;
        [_rightBt setTitle:@"全选" forState:UIControlStateNormal];
    }
}
- (void)bottomLeftAction {
    _isDelete = NO;
    _bottomView.hidden = YES;
    [_historyData enumerateObjectsUsingBlock:^(NSArray *monthModels, NSUInteger idx, BOOL * _Nonnull stop) {
        [monthModels enumerateObjectsUsingBlock:^(FaceHistoryModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            model.isSelDelete = NO;
        }];
    }];
    [self reloadColletionView];
    [_rightBt setTitle:@"删除" forState:UIControlStateNormal];
}
- (void)bottomRightAction {
    if(_isDelete){
        UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否确认删除" preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        UIAlertAction *removeAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self certainDelete];
        }];
        [alertCon addAction:cancelAction];
        [alertCon addAction:removeAction];
        if (alertCon.popoverPresentationController != nil) {
            alertCon.popoverPresentationController.sourceView = _bottomView;
            alertCon.popoverPresentationController.sourceRect = _bottomView.bounds;
        }
        [self presentViewController:alertCon animated:YES completion:^{
        }];
    }
}
- (void)certainDelete {
    NSMutableArray *delArys = @[].mutableCopy;
    NSMutableString *faceId = @"".mutableCopy;
    [_historyData enumerateObjectsUsingBlock:^(NSArray *monthModels, NSUInteger groupIdx, BOOL * _Nonnull stop) {
        [monthModels enumerateObjectsUsingBlock:^(FaceHistoryModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
            if(model.isSelDelete){
                [faceId appendFormat:@"%@,", model.uuid];
                [delArys addObject:[NSIndexPath indexPathForRow:idx inSection:groupIdx]];
            }
        }];
    }];
    
    if(faceId.length > 0){
        [faceId deleteCharactersInRange:NSMakeRange(faceId.length - 1, 1)];
    }else {
        return;
    }
    // 删除所选
    NSString *urlStr = [NSString stringWithFormat:@"%@/faceRecognition/delBatchFaceQueryHis", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:faceId forKey:@"uuids"];
    
    NSString *paramStr = [Utils convertToJsonData:paramDic];
    NSDictionary *params = @{@"param":paramStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        
        NSString *code = responseObject[@"code"];
        if (code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]) {
            
            [self _loadHistoryData];
            //                [self reloadColletionView];
        }
        NSString *message = responseObject[@"message"];
        if(message != nil && ![message isKindOfClass:[NSNull class]]){
            [self showHint:message];
        }
    } failure:^(NSError *error) {
        [self showHint:KRequestFailMsg];
    }];
}

- (void)reloadColletionView {
    if(_historyData.count <= 0){
        _noDataView.hidden = NO;
    }else {
        _noDataView.hidden = YES;
    }
    [_collectionView reloadData];
}

- (void)_loadHistoryData {
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/faceRecognition/queryFaceQueryHis", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:[NSNumber numberWithInteger:_page] forKey:@"pageNumber"];
    [paramDic setObject:[NSNumber numberWithInteger:_length] forKey:@"pageSize"];
    [paramDic setObject:[[NSUserDefaults standardUserDefaults] objectForKey:KDeviceUUID] forKey:@"equId"];
    
    NSString *paramStr = [Utils convertToJsonData:paramDic];
    NSDictionary *params = @{@"param":paramStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        [_collectionView.mj_header endRefreshing];
        [_collectionView.mj_footer endRefreshing];
        
        NSString *code = responseObject[@"code"];
        if (code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]) {
            if(_page == 1){
                [_hisDatas removeAllObjects];
            }
            NSArray *arr = responseObject[@"responseData"];
            
            if(arr.count > _length-1){
                _collectionView.mj_footer.state = MJRefreshStateIdle;
                _collectionView.mj_footer.hidden = NO;
            }else {
                _collectionView.mj_footer.state = MJRefreshStateNoMoreData;
                _collectionView.mj_footer.hidden = YES;
            }
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FaceHistoryModel *model = [[FaceHistoryModel alloc] initWithDataDic:obj];
                [_hisDatas addObject:model];
            }];
            
            // 处理数据
            [self dealData:_hisDatas];
        }
        [self reloadColletionView];
        
    } failure:^(NSError *error) {
        [_collectionView.mj_header endRefreshing];
        [_collectionView.mj_footer endRefreshing];
        
        if(_historyData.count <= 0){
            [self showNoDataImage];
        }else {
            [self showHint:KRequestFailMsg];
        }
    }];
}
- (void)dealData:(NSArray *)billData {
    if(billData.count <= 0){
        return;
    }
    [_historyTitleData removeAllObjects];
    [_historyData removeAllObjects];
    
    NSMutableArray *monthData = @[].mutableCopy;
    
    FaceHistoryModel *friModel = billData.firstObject;
    __block NSDate *friDate = [self timeStrWithInt:friModel.createTime];
    
    NSDateFormatter *newFormat = [[NSDateFormatter alloc] init];
    [newFormat setDateFormat:@"yyyy年MM月dd日"];
    __block NSString *friDateStr = [newFormat stringFromDate:friDate];
    
    [billData enumerateObjectsUsingBlock:^(FaceHistoryModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDate *billDate = [self timeStrWithInt:friModel.createTime];
        NSString *billDateStr = [newFormat stringFromDate:billDate];
        
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents *friComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:friDate];
        NSDateComponents *billComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:billDate];
        
        if(friComponents.year == billComponents.year){
            if(friComponents.month == billComponents.month){
                // 同月
                [monthData addObject:model];
            }else {
                [_historyTitleData addObject:[friDateStr substringWithRange:NSMakeRange(0, 8)]];
                [_historyData addObject:monthData.copy];
                [monthData removeAllObjects];
                friDate = billDate;
                friDateStr = billDateStr;
                
                [monthData addObject:model];
            }
            
        }else {
            [_historyTitleData addObject:[friDateStr substringWithRange:NSMakeRange(0, 8)]];
            [_historyData addObject:monthData.copy];
            [monthData removeAllObjects];
            friDate = billDate;
            friDateStr = billDateStr;
            
            if(friComponents.month == billComponents.month){
                // 同月
                [monthData addObject:model];
            }else {
                [_historyTitleData addObject:[friDateStr substringWithRange:NSMakeRange(0, 8)]];
                [_historyData addObject:monthData.copy];
                [monthData removeAllObjects];
                friDate = billDate;
                friDateStr = billDateStr;
                
                [monthData addObject:model];
            }
        }
        
    }];
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents *friComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:friDate];
    NSDateComponents *newComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate new]];
    
    if(friComponents.year == newComponents.year){
        [_historyTitleData addObject:[friDateStr substringWithRange:NSMakeRange(0, 8)]];
        [_historyData addObject:monthData.copy];
    }else {
        [_historyTitleData addObject:[friDateStr substringWithRange:NSMakeRange(0, 8)]];
        [_historyData addObject:monthData.copy];
    }
}
- (NSDate *)timeStrWithInt:(NSNumber *)time {
    if(time == nil || [time isKindOfClass:[NSNull class]]){
        return [NSDate date];
    }
    //时间戳转化成时间
    NSDateFormatter *stampFormatter = [[NSDateFormatter alloc] init];
    [stampFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *stampDate = [NSDate dateWithTimeIntervalSince1970:time.doubleValue/1000.0];
    return stampDate;
}

#pragma mark UICollectionView 协议
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _historyTitleData.count;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *hisAry = _historyData[section];
    return hisAry.count;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemWidth = KScreenWidth/4 - 1.5;
    return CGSizeMake(itemWidth, itemWidth);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(1.0, 1.0, 0.0, 1.0);
}
//header的size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(nonnull UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(KScreenWidth, 40);
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"reusableView" forIndexPath:indexPath];
    footerView.backgroundColor =[UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 20)];
    label.text = _historyTitleData[indexPath.section];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:15];
    label.textAlignment = NSTextAlignmentLeft;
    [footerView addSubview:label];
    
    return footerView;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FaceHistoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FaceHistoryCell" forIndexPath:indexPath];
    FaceHistoryModel *imgModel = _historyData[indexPath.section][indexPath.row];
    cell.faceHistoryModel = imgModel;
    cell.isShowDelete = _isDelete;
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
     FaceHistoryModel *imgModel = _historyData[indexPath.section][indexPath.row];
    if(_selClientHistoryImgDelegate != nil && [_selClientHistoryImgDelegate respondsToSelector:@selector(selHistoryImg:)]){
        [_selClientHistoryImgDelegate selHistoryImg:imgModel];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
