//
//  FaceHistoryViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/13.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "FaceHistoryViewController.h"
#import "FaceHistoryCell.h"
#import "FaceCoreDataManager.h"

@interface FaceHistoryViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_collectionView;
    NSMutableArray *_historyTitleData;
    NSMutableArray *_historyData;
    
}
@end

@implementation FaceHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _historyTitleData = @[].mutableCopy;
    _historyData = @[].mutableCopy;
    
    self.title = @"选择历史照片";
    
    [self _initView];
    
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
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 1;
    layout.minimumLineSpacing = 1;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight) collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView registerNib:[UINib nibWithNibName:@"FaceHistoryCell" bundle:nil] forCellWithReuseIdentifier:@"FaceHistoryCell"];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"reusableView"];
    [self.view addSubview:_collectionView];
    
}
-(void)_leftBarBtnItemClick:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_loadHistoryData {
    // 查询sqlite数据库
    FaceCoreDataManager *dataManager = [FaceCoreDataManager shareManager];

    NSArray *faceData = [dataManager query:@"FaceImgHistory" predicate:nil];
    NSLog(@"%@", faceData);
    [self dealData:faceData];
    
    [_collectionView reloadData];
}
- (void)dealData:(NSArray *)billData {
    if(billData.count <= 0){
        return;
    }
    [_historyTitleData removeAllObjects];
    [_historyData removeAllObjects];
    
    NSMutableArray *monthData = @[].mutableCopy;
    
    FaceImgHistory *friModel = billData.firstObject;
    __block NSDate *friDate = friModel.selTime;
    
    NSDateFormatter *newFormat = [[NSDateFormatter alloc] init];
    [newFormat setDateFormat:@"yyyy年MM月dd日"];
    __block NSString *friDateStr = [newFormat stringFromDate:friDate];
    
    [billData enumerateObjectsUsingBlock:^(FaceImgHistory *model, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDate *billDate = model.selTime;
        NSString *billDateStr = [newFormat stringFromDate:billDate];
        
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents *friComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:friDate];
        NSDateComponents *billComponents = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:billDate];
        
        if(friComponents.year == billComponents.year){
            if(friComponents.month == billComponents.month){
                // 同月
                [monthData addObject:model];
            }else {
//                [_historyTitleData addObject:[friDateStr substringWithRange:NSMakeRange(5, 3)]];
                [_historyTitleData addObject:[friDateStr substringWithRange:NSMakeRange(0, 8)]];
                [_historyData addObject:monthData.copy];
                [monthData removeAllObjects];
                friDate = billDate;
                friDateStr = billDateStr;
                
                [monthData addObject:model];
            }
            
        }else {
//            [_historyTitleData addObject:[friDateStr substringWithRange:NSMakeRange(5, 3)]];
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
//        [_historyTitleData addObject:[friDateStr substringWithRange:NSMakeRange(5, 3)]];
        [_historyTitleData addObject:[friDateStr substringWithRange:NSMakeRange(0, 8)]];
        [_historyData addObject:monthData.copy];
    }else {
        [_historyTitleData addObject:[friDateStr substringWithRange:NSMakeRange(0, 8)]];
        [_historyData addObject:monthData.copy];
    }
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
    FaceImgHistory *imgModel = _historyData[indexPath.section][indexPath.row];
    cell.faceImgHistory = imgModel;
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    FaceImgHistory *imgModel = _historyData[indexPath.section][indexPath.row];
    if(_selHistoryImgDelegate != nil && [_selHistoryImgDelegate respondsToSelector:@selector(selHistoryImg:)]){
        [_selHistoryImgDelegate selHistoryImg:imgModel];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
