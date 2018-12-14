//
//  VisitedViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/18.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "VisitedViewController.h"
#import "VisitedTableViewCell.h"
#import "NoDataView.h"
#import "VisitorFinishModel.h"

#import "FaceQueryModel.h"

#import "FaceListViewController.h"
#import "UIImage+Zip.h"

@interface VisitedViewController ()<UITableViewDelegate,UITableViewDataSource,isArraiveCallTelePhoneDelegate, CYLTableViewPlaceHolderDelegate>
{
    NSMutableArray *_visData;
    UITableView *_vistionTableView;
    
    NSInteger _page;
    NSInteger _length;
    
    NSString *_startTime;
    NSString *_endTime;
    NSString *_visitorName;
    
    FaceQueryModel *_faceQueryModel;
    
    NSInteger _selIndex;
}
@end

@implementation VisitedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _visData = @[].mutableCopy;
    _page = 1;
    _length = 10;
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    
    [self _initView];
    
    [self _initData:NO];
}

-(void)_initView
{
    _vistionTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight-64-50) style:UITableViewStylePlain];
    _vistionTableView.delegate = self;
    _vistionTableView.dataSource = self;
//    _vistionTableView.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    _vistionTableView.backgroundColor = [UIColor clearColor];
    _vistionTableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    _vistionTableView.tableFooterView = [UIView new];
    [self.view addSubview:_vistionTableView];
    
    // ios 11tableView闪动
    _vistionTableView.estimatedRowHeight = 0;
    _vistionTableView.estimatedSectionHeaderHeight = 0;
    _vistionTableView.estimatedSectionFooterHeight = 0;
    
    [_vistionTableView registerNib:[UINib nibWithNibName:@"VisitedTableViewCell" bundle:nil] forCellReuseIdentifier:@"VisitedTableViewCell"];
    
    _vistionTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 1;
        [self _initData:NO];
    }];
    // 上拉刷新
    _vistionTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _page ++;
        [self _initData:NO];
    }];
//    _vistionTableView.mj_footer.automaticallyHidden = NO;
    _vistionTableView.mj_footer.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterAction:) name:@"VisitorFilter" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterResSet) name:@"VisitorResSet" object:nil];
    
}

- (void)_initData:(BOOL)isTop {
    // 请求访客数据
    NSString *urlStr = [NSString stringWithFormat:@"%@/visitor/detail",Main_Url];
    
    NSMutableDictionary *searchParam = @{}.mutableCopy;
    [searchParam setObject:[NSNumber numberWithInteger:_length] forKey:@"pageSize"];
    [searchParam setObject:[NSNumber numberWithInteger:_page] forKey:@"pageNumber"];
    [searchParam setObject:@"0" forKey:@"type"];
    if(_visitorName != nil){
        [searchParam setObject:_visitorName forKey:@"visitorName"];
    }
    if(_startTime != nil && _startTime.length > 0){
        [searchParam setObject:_startTime forKey:@"startTime"];
    }
    if(_endTime != nil && _endTime.length > 0){
        [searchParam setObject:_endTime forKey:@"endTime"];
    }
    
    NSString *jsonStr = [self convertToJsonData:searchParam];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        
        [_vistionTableView.mj_header endRefreshing];
        [_vistionTableView.mj_footer endRefreshing];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSArray *items = responseObject[@"responseData"][@"items"];
            if(items.count > _length-1){
                _vistionTableView.mj_footer.state = MJRefreshStateIdle;
                _vistionTableView.mj_footer.hidden = NO;
            }else {
                _vistionTableView.mj_footer.state = MJRefreshStateNoMoreData;
                _vistionTableView.mj_footer.hidden = YES;
            }
            if(_page == 1){
                [_visData removeAllObjects];
            }
            [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                VisitorFinishModel *model = [[VisitorFinishModel alloc] initWithDataDic:obj];
                [_visData addObject:model];
            }];
        }
        
        [_vistionTableView cyl_reloadData];
        
        if(isTop){
            [_vistionTableView setContentOffset:CGPointMake(0, 0) animated:YES];
        }
    } failure:^(NSError *error) {
        [_vistionTableView.mj_header endRefreshing];
        [_vistionTableView.mj_footer endRefreshing];
        if(_visData.count <= 0){
            [self showNoDataImage];            
        }else {
            [self showHint:KRequestFailMsg];
        }
    }];
}
// 无网络重载
- (void)reloadTableData {
    [self _initData:NO];
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDateView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 60)];
    return noDateView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

#pragma mark UITableView 协议
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _visData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VisitedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VisitedTableViewCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.visitorFinishModel = _visData[indexPath.row];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 275;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 拨打电话代理
-(void)isArraiveCallTelePhone:(NSString *)telephone
{
    //获取目标号码字符串,转换成URL
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",telephone]];
    //调用系统方法拨号
    [kApplication openURL:url];
}
// 人脸
- (void)faceQuery:(VisitorFinishModel *)visitorFinishModel {
    // 通过访客机才有人脸图片
    if(visitorFinishModel.unit != nil && ![visitorFinishModel.unit isKindOfClass:[NSNull class]] && [visitorFinishModel.unit isEqualToString:@"2"]){
        return;
    }
    
    _selIndex = [_visData indexOfObject:visitorFinishModel];
    // 判断是否有图片，并 sdwebimage 加载图片再转为data
    if(visitorFinishModel.sitePhoto != nil && ![visitorFinishModel.sitePhoto isKindOfClass:[NSNull class]] && visitorFinishModel.sitePhoto.length > 0){
        // 下载
        [self showHudInView:self.view hint:@""];
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:visitorFinishModel.sitePhoto] options:SDWebImageProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            // 上传查询人像
            if(finished){
                if(image != nil){
                    [self imageData:image];
                }else {
                    [self hideHud];
                    [self showHint:@"图片加载失败"];
                }
            }
        }];
    }else {
        [self showHint:@"无访客图片"];
    }

}

#pragma mark 筛选通知
- (void)filterAction:(NSNotification *)notification {
    NSString *startTime = notification.userInfo[@"startTime"];
    NSString *endTime = notification.userInfo[@"endTime"];
    
    _startTime = [self timeFormatWithStyle:@"yyyy-MM-dd HH:mm" withTimeStr:startTime];
    _endTime = [self timeFormatWithStyle:@"yyyy-MM-dd HH:mm" withTimeStr:endTime];
    _visitorName = notification.userInfo[@"visitorName"];
    
    _page = 1;
    [self _initData:YES];
}

// 重置
- (void)filterResSet {
    if(_startTime != nil && _endTime != nil){
        _startTime = nil;
        _endTime = nil;
        _visitorName = nil;
        
        _page = 1;
        [self _initData:YES];
    }
}

// 格式化时间字符
- (NSString *)timeFormatWithStyle:(NSString *)style withTimeStr:(NSString *)timeStr {
    NSDateFormatter *oldFormat = [[NSDateFormatter alloc] init];
    [oldFormat setDateFormat:style];
    NSDate *date = [oldFormat dateFromString:timeStr];
    
    NSDateFormatter *inputFormat = [[NSDateFormatter alloc] init];
    [inputFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [inputFormat stringFromDate:date];
}

- (NSString *)convertToJsonData:(NSDictionary *)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range];
    return mutStr;
}

#pragma mark 图片压缩至2M以内
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
    
    // 清除上次选择图片
    _faceQueryModel = nil;
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        if(responseObject[@"code"] != nil && ![responseObject[@"code"] isKindOfClass:[NSNull class]] && [responseObject[@"code"] isEqualToString:@"1"]){
            
            _faceQueryModel = [[FaceQueryModel alloc] initWithDataDic:responseObject[@"responseData"]];
            
            // 如果访客带有人脸照片，跳转查询轨迹列表
            FaceListViewController *faceListVC = [[FaceListViewController alloc] init];
            faceListVC.faceModel = _faceQueryModel;
            // 开始当前前一个月时间 结束当前时间 yyyy-MM-dd HH:mm 相似度90%
            faceListVC.beginTime = [self getCurrentDateStr:YES];
            faceListVC.endTime = [self getCurrentDateStr:NO];
            faceListVC.threshold = [NSNumber numberWithFloat:90];
            
            NSString *base64Str = [_faceQueryModel.imgBase64 componentsSeparatedByString:@"base64,"].lastObject;
            
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
