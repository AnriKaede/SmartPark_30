//
//  FaceWranViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/13.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "FaceWranViewController.h"
#import "FaceWranCell.h"
#import "UIImage+Zip.h"
#import "FaceWranModel.h"
#import "AddAloneFaceViewController.h"

@interface FaceWranViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TZImagePickerControllerDelegate, UpdateImgDelegate>
{
    UICollectionView *_collectionView;
    NSMutableArray *_wranData;
    
    NSInteger _page;
    NSInteger _length;
    
    UIView *_bottomView;
    
    BOOL _isDelete;
    
    UIButton *_allSelBt;
}
@end

@implementation FaceWranViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"人像告警";
    _wranData = @[].mutableCopy;
    
    _page = 1;
    _length = 32;
    
    [self _initView];
    
    [self _createBottomView];
    
    [self loadFaceData];
}

- (void)_initView {
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _allSelBt = [UIButton buttonWithType:UIButtonTypeCustom];
    _allSelBt.frame = CGRectMake(0, 0, 40, 40);
    _allSelBt.hidden = YES;
    [_allSelBt setTitle:@"全选" forState:UIControlStateNormal];
    [_allSelBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_allSelBt addTarget:self action:@selector(allSelect) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_allSelBt];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 1;
    layout.minimumLineSpacing = 1;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight - 60) collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView registerNib:[UINib nibWithNibName:@"FaceWranCell" bundle:nil] forCellWithReuseIdentifier:@"FaceWranCell"];
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
}

-(void)_leftBarBtnItemClick:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)allSelect {
    // 全选
    [_wranData enumerateObjectsUsingBlock:^(FaceWranModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        model.isSelDelete = YES;
    }];
    [_collectionView reloadData];
}

#pragma mark 请求数据
- (void)loadFaceData {
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
                [_wranData removeAllObjects];
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
                [_wranData addObject:model];
            }];
            
        }
        [_collectionView reloadData];
        
    } failure:^(NSError *error) {
        [_collectionView.mj_header endRefreshing];
        [_collectionView.mj_footer endRefreshing];
        
        if(_wranData.count <= 0){
            [self showNoDataImage];
        }else {
            [self showHint:KRequestFailMsg];
        }
    }];
    
}
// 无网络重载
- (void)reloadTableData {
    [self loadFaceData];
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 60, KScreenWidth, KScreenHeight - 63)];
    return noDataView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

- (void)_createBottomView {
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, KScreenHeight - kTopHeight - 60, KScreenWidth, 60)];
    _bottomView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:_bottomView];
    
    NSString *leftTitle = @"";
    if(_isDelete){
        leftTitle = @"取消";
    }else {
        leftTitle = @"删除人像";
    }
    UIButton *bottomLeftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    bottomLeftButton.tag = 2001;
    bottomLeftButton.frame = CGRectMake(0, 0, KScreenWidth/2, _bottomView.height);
    [bottomLeftButton setBackgroundImage:[UIImage imageNamed:@"scene_all_close_bg"] forState:UIControlStateNormal];
    [bottomLeftButton setTitle:leftTitle forState:UIControlStateNormal];
    [bottomLeftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [bottomLeftButton addTarget:self action:@selector(bottomLeftAction) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:bottomLeftButton];
    
    NSString *rightTitle = @"";
    if(_isDelete){
        rightTitle = @"删除所选";
    }else {
        rightTitle = @"新增人像";
    }
    UIButton *bottomRightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    bottomRightButton.tag = 2002;
    bottomRightButton.frame = CGRectMake(KScreenWidth/2, 0, KScreenWidth/2, _bottomView.height);
    bottomRightButton.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
    [bottomRightButton setTitle:rightTitle forState:UIControlStateNormal];
    [bottomRightButton setTitleColor:[UIColor colorWithHexString:@"#CCFF00"] forState:UIControlStateNormal];
    [bottomRightButton addTarget:self action:@selector(bottomRightAction) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:bottomRightButton];
    
}
- (void)bottomLeftAction {
    UIButton *bottomLeftButton = [_bottomView viewWithTag:2001];
    UIButton *bottomRightButton = [_bottomView viewWithTag:2002];
    if(_isDelete){
        // 取消
        _isDelete = NO;
        [bottomLeftButton setTitle:@"删除人像" forState:UIControlStateNormal];
        [bottomRightButton setTitle:@"新增人像" forState:UIControlStateNormal];
        _allSelBt.hidden = YES;
    }else {
        // 删除人像
        _isDelete = YES;
        [bottomLeftButton setTitle:@"取消" forState:UIControlStateNormal];
        [bottomRightButton setTitle:@"删除所选" forState:UIControlStateNormal];
        _allSelBt.hidden = NO;
    }
    [_collectionView reloadData];
}
- (void)bottomRightAction {
    if(_isDelete){
        // 删除所选
    }else {
        // 新增人像
        [self selFacePhoto];
    }
}
#pragma mark 选择人脸图片
- (void)selFacePhoto {
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingGif = NO;
    
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
#warning 选择多张图片，上传测试是否包含人像信息
        NSLog(@"%@", photos);
        if(photos.count == 1){
            AddAloneFaceViewController *aloneVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"AddAloneFaceViewController"];
            [self.navigationController pushViewController:aloneVC animated:YES];
        }
        // 判断图片是否存在头像
//        [self imageData:photos.firstObject];
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark UICollectionView 协议
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _wranData.count;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat itemWidth = KScreenWidth/4 - 1.5;
    return CGSizeMake(itemWidth, itemWidth);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(1.0, 1.0, 0.0, 1.0);
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FaceWranCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FaceWranCell" forIndexPath:indexPath];
    cell.isDelete = _isDelete;
    cell.updateImgDelegate = self;
    cell.faceWranModel = _wranData[indexPath.row];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark cell协议，更新人像
- (void)updateImg:(FaceWranModel *)faceWranModel {
    
}

#pragma mark 图片压缩至2M以内
- (void)imageData:(UIImage *)image {
    NSData *data = [UIImage compressWithOrgImg:image];
    if(data.length/1024 < 2*1024){
        // 小于2M 结束
        [self uploadFaceImage:data withImg:image];
    }else {
        UIImage *dataImage = [UIImage imageWithData:data];
        [self imageData:dataImage];
    }
}
- (void)uploadFaceImage:(NSData *)data withImg:(UIImage *)selImage {
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
            
            NSLog(@"%@", responseObject[@"responseData"]);
            
        }else {
            if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]] ) {
                [self showHint:responseObject[@"message"]];
            }
        }
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
    }];
    
}

@end
