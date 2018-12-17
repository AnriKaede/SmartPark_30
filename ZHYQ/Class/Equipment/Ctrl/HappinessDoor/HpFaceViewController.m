//
//  HpFaceViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/12/17.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "HpFaceViewController.h"
#import "HpFaceCell.h"

@interface HpFaceViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    UICollectionView *_collectionView;
    NSMutableArray *_faceData;
    
    NSInteger _page;
    NSInteger _length;
    
    NoDataView *_noDataView;
}
@end

@implementation HpFaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _faceData = @[].mutableCopy;
    
    _page = 1;
    _length = 32;
    
    [self _initView];
    
    [self loadFaceData];
}
- (void)_initView {
    self.view.backgroundColor = [UIColor colorWithHexString:@"#EFEFEF"];
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 4;
    layout.minimumLineSpacing = 8;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight - 60) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor colorWithHexString:@"#EFEFEF"];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView registerNib:[UINib nibWithNibName:@"HpFaceCell" bundle:nil] forCellWithReuseIdentifier:@"HpFaceCell"];
    [self.view addSubview:_collectionView];
    
    _collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 1;
        [self loadFaceData];
    }];
    // 上拉刷新
    _collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _page ++;
        [self loadFaceData];
    }];
    _collectionView.mj_footer.hidden = YES;
    
    // 无数据视图
    _noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64-49)];
    _noDataView.hidden = YES;
    [self.view addSubview:_noDataView];
}

-(void)_leftBarBtnItemClick:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 请求数据
- (void)loadFaceData {
    /*
    NSString *urlStr = [NSString stringWithFormat:@"%@/faceRecognition/getAlarmIamges", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:[NSNumber numberWithInteger:_page] forKey:@"pageNumber"];
    [paramDic setObject:[NSNumber numberWithInteger:_length] forKey:@"pageSize"];
    
    [paramDic setObject:@"19" forKey:@"repository"];
    
    NSString *paramStr = [Utils convertToJsonData:paramDic];
    NSDictionary *params = @{@"param":paramStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        
        [_collectionView.mj_header endRefreshing];
        [_collectionView.mj_footer endRefreshing];
        
        NSString *code = responseObject[@"code"];
        
        if (code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]) {
            if(_page == 1){
                [_faceData removeAllObjects];
            }
            
            NSDictionary *dic = responseObject[@"responseData"];
            NSArray *arr = dic[@"items"];
            
            if(arr.count > _length-1){
                _collectionView.mj_footer.state = MJRefreshStateIdle;
                _collectionView.mj_footer.hidden = NO;
            }else {
                _collectionView.mj_footer.state = MJRefreshStateNoMoreData;
                _collectionView.mj_footer.hidden = YES;
            }
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FaceWranModel *model = [[FaceWranModel alloc] initWithDataDic:obj];
                [_faceData addObject:model];
            }];
            
        }
        [self reloadCollectionView];
        
    } failure:^(NSError *error) {
        [_collectionView.mj_header endRefreshing];
        [_collectionView.mj_footer endRefreshing];
        
        if(_faceData.count <= 0){
            [self showNoDataImage];
        }else {
            [self showHint:KRequestFailMsg];
        }
    }];
    */
}
// 无网络重载
- (void)reloadTableData {
    [self loadFaceData];
}

- (void)reloadCollectionView {
    if(_faceData.count <= 0){
        _noDataView.hidden = NO;
    }else {
        _noDataView.hidden = YES;
    }
    [_collectionView reloadData];
}

#pragma mark UICollectionView 协议
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
//    return _faceData.count;
    return 6;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemWidth = KScreenWidth/3 - 10;
    return CGSizeMake(itemWidth, 1.2*itemWidth);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(4.0, 4.0, 0.0, 4.0);
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HpFaceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HpFaceCell" forIndexPath:indexPath];
//    cell.faceWranModel = _faceData[indexPath.row];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
