//
//  AddBatchViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/28.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "AddBatchViewController.h"
#import "BatchAddFaceCell.h"
#import "AddBatchFaceModel.h"

@interface AddBatchViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_collectionView;
    NSMutableArray *_batchFaceData;
}
@end

@implementation AddBatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _batchFaceData = @[].mutableCopy;
    
    [self _initView];
    
    [self loadData];
    
    UITapGestureRecognizer *editEndTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEdit)];
    [self.view addGestureRecognizer:editEndTap];
}
- (void)endEdit {
    [self.view endEditing:YES];
}

- (void)loadData {
    [_selImgs enumerateObjectsUsingBlock:^(UIImage *faceImg, NSUInteger idx, BOOL * _Nonnull stop) {
        AddBatchFaceModel *model = [[AddBatchFaceModel alloc] init];
        model.faceImage = faceImg;
        [_batchFaceData addObject:model];
    }];
    
    [_collectionView reloadData];
}

- (void)_initView {
    self.title = @"新增人像";
    
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#EFEFEF"];
    
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
    _collectionView.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF"];
    [_collectionView registerNib:[UINib nibWithNibName:@"BatchAddFaceCell" bundle:nil] forCellWithReuseIdentifier:@"BatchAddFaceCell"];
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"reusableView"];
}

-(void)_leftBarBtnItemClick:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UICollectionView 协议
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _batchFaceData.count;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemWidth = KScreenWidth/3 - 4;
    return CGSizeMake(itemWidth, itemWidth*1.22);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(KScreenWidth, 100);
}
 - (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
     UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"reusableView" forIndexPath:indexPath];
     footerView.backgroundColor =[UIColor clearColor];
     
     UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
     button.frame = CGRectMake((KScreenWidth - 150)/2, 30, 150, 50);
     [button setTitle:@"确认新增" forState:UIControlStateNormal];
     [button setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
     [button addTarget:self action:@selector(certainAdd) forControlEvents:UIControlEventTouchUpInside];
     button.titleLabel.font = [UIFont systemFontOfSize:17];
     button.layer.cornerRadius = 4;
     button.layer.borderWidth = 1;
     button.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
     [footerView addSubview:button];
     
     return footerView;
 }
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(1.0, 1.0, 0.0, 1.0);
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BatchAddFaceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BatchAddFaceCell" forIndexPath:indexPath];
    cell.addBatchFaceModel = _batchFaceData[indexPath.row];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark 确认新增
- (void)certainAdd {
    
}

@end
