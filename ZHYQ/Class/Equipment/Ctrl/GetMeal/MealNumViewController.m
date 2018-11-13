//
//  MealNumViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/5.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "MealNumViewController.h"
#import "GetMealCell.h"

@interface MealNumViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_collectionView;
    NSMutableArray *_sceneData;
    
    NSMutableArray *_selNumData;
}
@end

@implementation MealNumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _sceneData = @[].mutableCopy;
    _selNumData = @[].mutableCopy;
    for (int i=1; i<=16; i++) {
        if(i + _index*16 == 1){
            [_selNumData addObject:[NSNumber numberWithBool:YES]];
        }else {
            [_selNumData addObject:[NSNumber numberWithBool:NO]];
        }
    }
    
    [self _initView];
    
    [self _loadSceneData];
}

- (void)_initView {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 150 - kTopHeight) collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView registerNib:[UINib nibWithNibName:@"GetMealCell" bundle:nil] forCellWithReuseIdentifier:@"GetMealCell"];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"reusableView"];
    [self.view addSubview:_collectionView];
    
//    _collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//        [self _loadSceneData];
//    }];
}

- (void)_loadSceneData {
    [_collectionView.mj_header endRefreshing];
    [_collectionView reloadData];
}

#pragma mark UICollectionView 协议
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(_index == 3){
        return 2;
    }
    return _selNumData.count;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    CGFloat itemWidth = (KScreenWidth - 10)/4 - 5;
    return CGSizeMake(83, 50);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(4, 4, 4, 4);
}
//footer的size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(KScreenWidth, 100);
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"reusableView" forIndexPath:indexPath];
    footerView.backgroundColor =[UIColor clearColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake((KScreenWidth - 250)/2, 30, 250, 50);
    [button setTitle:@" 请取餐" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"get_meal_call"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(callMeal) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font = [UIFont systemFontOfSize:17];
    button.layer.cornerRadius = 4;
    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
    [footerView addSubview:button];
    
    return footerView;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GetMealCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GetMealCell" forIndexPath:indexPath];
    cell.numStr = [NSString stringWithFormat:@"%ld", indexPath.row + 16*_index + 1];
    
    NSNumber *sel = _selNumData[indexPath.row];
    cell.isSelect = sel.boolValue;
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [_selNumData enumerateObjectsUsingBlock:^(NSNumber *selNum, NSUInteger idx, BOOL * _Nonnull stop) {
        if(indexPath.row == idx){
            selNum = [NSNumber numberWithBool:YES];
        }else {
            selNum = [NSNumber numberWithBool:NO];
        }
        [_selNumData replaceObjectAtIndex:idx withObject:selNum];
    }];
    [_collectionView reloadData];
}

- (void)callMeal {
    
}

@end
