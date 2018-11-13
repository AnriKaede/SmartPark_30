//
//  FaceListViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/3/28.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "FaceListViewController.h"
#import "FaceTraceCell.h"
#import "FaceListModel.h"

#import "FaceDetailViewController.h"

#import "NoDataView.h"

#import "DCSildeBarView.h"

#import "FaceFilterView.h"

@interface FaceListViewController ()<UITableViewDelegate, UITableViewDataSource, FaceFilterTimeDelegate>
{
    UITableView *_traceTableView;
    NSMutableArray *_traceData;
    
    NSMutableDictionary *_filterDic;
    
    NSInteger _page;
    NSInteger _length;
    
    FaceFilterView *_faceFilterView;
    UIButton *filtrateBtn;
}
@end

@implementation FaceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _traceData = @[].mutableCopy;
    _filterDic = @{}.mutableCopy;
    
    _page = 1;
    _length = 8;
    
    [self _initNavView];
    
    [self _initView];
    
    [_traceTableView.mj_header beginRefreshing];
    
}

- (void)_initNavView {
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 7, 30, 30)];
    
    if(_faceModel.imgBase64 != nil && ![_faceModel.imgBase64 isKindOfClass:[NSNull class]]){
        NSString *base64Str = [_faceModel.imgBase64 componentsSeparatedByString:@"base64,"].lastObject;
        
        NSData *decodedImageData = [[NSData alloc] initWithBase64EncodedString:base64Str options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *decodedImage = [UIImage imageWithData:decodedImageData];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, titleView.width, titleView.height)];
        imgView.backgroundColor = [UIColor whiteColor];
        imgView.image = decodedImage;
        imgView.layer.cornerRadius = imgView.width/2;
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.layer.masksToBounds = YES;
        [titleView addSubview:imgView];
        
        self.navigationItem.titleView = titleView;
    }
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    filtrateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [filtrateBtn addTarget:self action:@selector(filtrateBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [filtrateBtn setImage:[UIImage imageNamed:@"nav_filter_down"] forState:UIControlStateNormal];
    [filtrateBtn setImage:[UIImage imageNamed:@"apt_filter_right_up"] forState:UIControlStateSelected];
    [filtrateBtn setTitle:@"筛选" forState:UIControlStateNormal];
    // button标题的偏移量
    filtrateBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -24, 0, filtrateBtn.imageView.bounds.size.width);
    // button图片的偏移量
    filtrateBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 37, 0, -filtrateBtn.titleLabel.bounds.size.width);
    [filtrateBtn sizeToFit];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:filtrateBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
}
-(void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark 筛选按钮
- (void)filtrateBtnClick {
    filtrateBtn.selected = !filtrateBtn.selected;
    //    [DCSildeBarView dc_showSildBarViewController:FaceFilter];
    _faceFilterView.hidden = !filtrateBtn.selected;
}

- (void)_initView {
    
    _traceTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 10, KScreenWidth, KScreenHeight - 64 - 10) style:UITableViewStylePlain];
    _traceTableView.delegate = self;
    _traceTableView.dataSource = self;
//    _traceTableView.contentInset = UIEdgeInsetsMake(10, 0, 0, 0);
    _traceTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    _traceTableView.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    _traceTableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_traceTableView];
    
    _traceTableView.estimatedRowHeight = 0;
    _traceTableView.estimatedSectionHeaderHeight = 0;
    _traceTableView.estimatedSectionFooterHeight = 0;
    
    [_traceTableView registerNib:[UINib nibWithNibName:@"FaceTraceCell" bundle:nil] forCellReuseIdentifier:@"FaceTraceCell"];
    
    _traceTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 1;
        [self _loadData];
    }];
    // 上拉刷新
    _traceTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _page ++;
        [self _loadData];
    }];
//    _traceTableView.mj_footer.automaticallyHidden = NO;
    _traceTableView.mj_footer.hidden = YES;
    
    // 筛选视图
    _faceFilterView = [[FaceFilterView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    _faceFilterView.filterTimeDelegate = self;
    [self.view addSubview:_faceFilterView];
}

// 筛选通知
- (void)filterDataDic:(NSDictionary *)filterDic {
    _page = 1;
    [_traceData removeAllObjects];
    
    [_traceTableView reloadData];
    
    _filterDic = filterDic.mutableCopy;
    [_traceTableView.mj_header beginRefreshing];
}

- (void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/faceRecognition/getMatching", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:[NSNumber numberWithInteger:_page] forKey:@"pageNumber"];
    [paramDic setObject:[NSNumber numberWithInteger:_length] forKey:@"pageSize"];
    
    [paramDic setObject:_faceModel.faceImageIdStr forKey:@"faceImageIdStr"];
    
    if([_filterDic.allKeys containsObject:@"threshold"]){
        [paramDic setObject:_filterDic[@"threshold"] forKey:@"threshold"];
    }else {
        [paramDic setObject:_threshold forKey:@"threshold"];
    }
    
    if([_filterDic.allKeys containsObject:@"startTime"]){
        [paramDic setObject:_filterDic[@"startTime"] forKey:@"startTime"];
    }else {
        if([self dateStrFormat:_beginTime] != nil){
            [paramDic setObject:[self dateStrFormat:_beginTime] forKey:@"startTime"];
        }
    }
    
    if([_filterDic.allKeys containsObject:@"endTime"]){
        [paramDic setObject:_filterDic[@"endTime"] forKey:@"endTime"];
    }else {
        if([self dateStrFormat:_endTime] != nil){
            [paramDic setObject:[self dateStrFormat:_endTime] forKey:@"endTime"];
        }
    }
    
    NSString *paramStr = [self convertToJsonData:paramDic];
    NSDictionary *params = @{@"param":paramStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        
        [_traceTableView.mj_header endRefreshing];
        [_traceTableView.mj_footer endRefreshing];
        
        NSString *code = responseObject[@"code"];
        
        if (code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]) {
            if(_page == 1){
                [_traceData removeAllObjects];
            }
            
            NSDictionary *dic = responseObject[@"responseData"];
            NSArray *arr = dic[@"items"];
            
            if(arr.count > _length-1){
                _traceTableView.mj_footer.state = MJRefreshStateIdle;
                _traceTableView.mj_footer.hidden = NO;
            }else {
                _traceTableView.mj_footer.state = MJRefreshStateNoMoreData;
                _traceTableView.mj_footer.hidden = YES;
            }
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FaceListModel *model = [[FaceListModel alloc] initWithDataDic:obj];
                [_traceData addObject:model];
            }];
            
        }
        [_traceTableView cyl_reloadData];
        
    } failure:^(NSError *error) {
        [_traceTableView.mj_header endRefreshing];
        [_traceTableView.mj_footer endRefreshing];
        
        if(_traceData.count <= 0){
            [self showNoDataImage];
        }else {
            [self showHint:KRequestFailMsg];
        }
    }];
    
}
// 无网络重载
- (void)reloadTableData {
    [self _loadData];
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 60, KScreenWidth, KScreenHeight - 63)];
    return noDataView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

#pragma mark UItableView协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _traceData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FaceListModel *model = _traceData[indexPath.row];
    
    FaceTraceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FaceTraceCell" forIndexPath:indexPath];
    
    cell.faceListModel = model;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FaceListModel *model = _traceData[indexPath.row];
 
    FaceDetailViewController *faceDetVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"FaceDetailViewController"];
    faceDetVC.faceListModel = model;
    faceDetVC.faceBase64 = _faceModel.imgBase64;
    faceDetVC.orgImage = _orgImage;

    [self presentViewController:faceDetVC animated:YES completion:nil];
}

- (NSString *)convertToJsonData:(NSDictionary *)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    
    if (!jsonData) {
        NSLog(@"%@",error);
    }else {
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range];
    return mutStr;
}

- (NSString *)dateStrFormat:(NSString *)timeStr {
    NSDateFormatter *showFormat = [[NSDateFormatter alloc] init];
    [showFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [showFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *showStartDate = [showFormat dateFromString:timeStr];
    
    NSDateFormatter *inputFormat = [[NSDateFormatter alloc] init];
    [inputFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [inputFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *inputStartStr = [inputFormat stringFromDate:showStartDate];
    
    return inputStartStr;
}

#pragma mark 筛选
- (void)closeFilter {
    filtrateBtn.selected = NO;
}
- (void)resetFilter {
    // 重置数据
    [_filterDic removeAllObjects];
}
- (void)filterWithStart:(NSString *)startTime withEndTime:(NSString *)endTime withSimValue:(NSNumber *)simValue {
    NSMutableDictionary *infoDic = @{@"startTime":startTime,
                                      @"endTime":endTime,
                                      @"threshold":simValue
                                     }.mutableCopy;
    
    [self filterDataDic:infoDic];
    filtrateBtn.selected = NO;
}

@end
