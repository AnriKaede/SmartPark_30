//
//  HPFaceListViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/1/28.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "HPFaceListViewController.h"
#import "HpFaceCell.h"
#import "HpFaceModel.h"
#import "UIImage+Zip.h"

#import "FaceQueryModel.h"
#import "FaceListViewController.h"

@interface HPFaceListViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>
{
    UICollectionView *_collectionView;
    NSMutableArray *_faceData;
    
    NSInteger _page;
    NSInteger _length;
    
    NoDataView *_noDataView;
    
}
@end

@implementation HPFaceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _faceData = @[].mutableCopy;
    
    _page = 1;
    _length = 12;
    
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
    layout.minimumInteritemSpacing = 8;
    layout.minimumLineSpacing = 4;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight - 40) collectionViewLayout:layout];
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
    _noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64-200)];
    _noDataView.hidden = YES;
    [self.view addSubview:_noDataView];
}

-(void)_leftBarBtnItemClick:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 请求数据
- (void)loadFaceData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/fumenController/getAllPic", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:[NSNumber numberWithInteger:_page] forKey:@"pageNumber"];
    [paramDic setObject:[NSNumber numberWithInteger:_length] forKey:@"pageSize"];
    NSString *paramStr = [Utils convertToJsonData:paramDic];
    NSDictionary *params = @{@"param":paramStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        
        [_collectionView.mj_header endRefreshing];
        [_collectionView.mj_footer endRefreshing];
        
        NSString *code = responseObject[@"code"];
        
        if (code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]) {
            NSArray *responseData = responseObject[@"responseData"];
            if(_page == 1){
                [_faceData removeAllObjects];
            }
            
            if(responseData.count > 0){
                NSDictionary *dic = responseData.firstObject;
                NSArray *arr = dic[@"returnList"];
                
                if(arr.count > _length-1){
                    _collectionView.mj_footer.state = MJRefreshStateIdle;
                    _collectionView.mj_footer.hidden = NO;
                }else {
                    _collectionView.mj_footer.state = MJRefreshStateNoMoreData;
                    _collectionView.mj_footer.hidden = YES;
                }
                
                [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    HpFaceModel *model = [[HpFaceModel alloc] initWithDataDic:obj];
                    [_faceData addObject:model];
                }];
            }
            
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
}

#pragma mark 返回前n秒 时间  单位秒
- (NSDate *)getNSecond:(NSInteger)n{
    NSDate*nowDate = [NSDate date];
    NSDate* theDate;
    if(n!=0){
        NSTimeInterval oneDay = n;
        theDate = [nowDate initWithTimeIntervalSinceNow: -oneDay*n ];
    }else{
        theDate = nowDate;
    }
    return theDate;
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
    return _faceData.count;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemWidth = KScreenWidth/3 - 10;
    return CGSizeMake(itemWidth, 1.27*itemWidth);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(2.0, 4.0, 1.0, 4.0);
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HpFaceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HpFaceCell" forIndexPath:indexPath];
    cell.hpFaceModel = _faceData[indexPath.row];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    HpFaceModel *hpFaceModel = _faceData[indexPath.row];
    
    [self showHudInView:self.view hint:@""];
    if(hpFaceModel.FACEPHOTO != nil && ![hpFaceModel.FACEPHOTO isKindOfClass:[NSNull class]] && [hpFaceModel.FACEPHOTO containsString:@"base64,"]){
        NSString *base64Str = [hpFaceModel.FACEPHOTO componentsSeparatedByString:@"base64,"].lastObject;
        NSData *decodedImageData = [[NSData alloc] initWithBase64EncodedString:base64Str options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *decodedImage = [UIImage imageWithData:decodedImageData];
        
        [self imageData:decodedImage];
    }else {
        [self hideHud];
    }
}

#pragma mark 点击人像查询人像记录
// 图片压缩至2M以内
- (void)imageData:(UIImage *)image {
    NSData *data = [UIImage compressWithOrgImg:image];
    if(data.length/1024 < 2*1024){
        // 小于2M 结束
        [self uploadFaceImage:data];
    }else {
        UIImage *dataImage = [UIImage imageWithData:data];
        [self imageData:dataImage];
    }
}
#pragma mark 上传图像获取人脸图片
- (void)uploadFaceImage:(NSData *)data {
    NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    encodedImageStr = [NSString stringWithFormat:@"data:image/jpeg;base64,%@", encodedImageStr];
    encodedImageStr = [encodedImageStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    encodedImageStr = [encodedImageStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/faceRecognition/imageUpload", Main_Url];
    NSMutableDictionary *param = @{}.mutableCopy;
    [param setObject:encodedImageStr forKey:@"base64EncodeImage"];
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        if(responseObject[@"code"] != nil && ![responseObject[@"code"] isKindOfClass:[NSNull class]] && [responseObject[@"code"] isEqualToString:@"1"]){
            
            FaceQueryModel *faceQueryModel = [[FaceQueryModel alloc] initWithDataDic:responseObject[@"responseData"]];
            
            // 如果访客带有人脸照片，跳转查询轨迹列表
            FaceListViewController *faceListVC = [[FaceListViewController alloc] init];
            faceListVC.faceModel = faceQueryModel;
            // 开始当前前一个月时间 结束当前时间 yyyy-MM-dd HH:mm 相似度90%
            faceListVC.beginTime = [self getCurrentDateStr:YES];
            faceListVC.endTime = [self getCurrentDateStr:NO];
            faceListVC.threshold = [NSNumber numberWithFloat:90];
            
            NSString *base64Str = [faceQueryModel.imgBase64 componentsSeparatedByString:@"base64,"].lastObject;
            
            NSData *decodedImageData = [[NSData alloc] initWithBase64EncodedString:base64Str options:NSDataBase64DecodingIgnoreUnknownCharacters];
            UIImage *decodedImage = [UIImage imageWithData:decodedImageData];
            faceListVC.orgImage = decodedImage;
            
            [self.navigationController pushViewController:faceListVC animated:YES];
            
        }else {
            if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]] ) {
                [self showHint:responseObject[@"message"]];
            }
        }
    } failure:^(NSError *error) {
        [self hideHud];
        [self showHint:KRequestFailMsg];
    }];
    
}

- (NSString *)getCurrentDateStr:(BOOL)isMonth {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    if(isMonth){
        NSString *monthDateStr = [dateFormatter stringFromDate:[self formatMonthDate]];
        return monthDateStr;
    }else {
        NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
        return currentDateStr;
    }
}

// 前一个月时间
- (NSDate *)formatMonthDate {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = nil;
    comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    [adcomps setYear:0];
    [adcomps setMonth:-1];
    [adcomps setDay:0];
    NSDate *newdate = [calendar dateByAddingComponents:adcomps toDate:[NSDate date] options:0];
    
    return newdate;
}

@end
