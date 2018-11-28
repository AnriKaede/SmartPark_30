//
//  SelFaceViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/3/28.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "SelFaceViewController.h"
#import "SelPhotoCell.h"
#import "SelTimeCell.h"
#import "SimilarValueCell.h"
#import "FaceQueryCell.h"
#import "WSDatePickerView.h"

#import "FaceQueryModel.h"

#import "FaceListViewController.h"

#import "FaceHistoryViewController.h"
#import "FaceWranViewController.h"

#import "FaceCoreDataManager.h"
#import "FaceImgHistory+CoreDataClass.h"
#import "UIImage+Zip.h"

@interface SelFaceViewController ()<UITableViewDelegate, UITableViewDataSource, SelFacePhotoDelegate, TZImagePickerControllerDelegate, FaceQueryDelegate, SelHistoryImgDelegate>
{
    UITableView *_selTableView;
    
    SelPhotoCell *_selPhotoCell;
    SelTimeCell *_beginSelTimeCell;
    SelTimeCell *_endSelTimeCell;
    SimilarValueCell *_similarValueCell;
    FaceQueryCell *_faceQueryCell;
    
    FaceQueryModel *_model;
    
    NSString *_beginTimeStr;
    NSString *_endTimeStr;
    
    NSString *_requestCode;
    NSString *_requestMsg;
}
@end

@implementation SelFaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
}

- (void)_initView {
    //    self.title = @"人脸轨迹";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIButton *imgWranBtn = [[UIButton alloc] init];
    imgWranBtn.frame = CGRectMake(0, 0, 40, 40);
    [imgWranBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
//    face_history_icon
    [imgWranBtn setImage:[UIImage imageNamed:@"face_history_icon"] forState:UIControlStateNormal];
    [imgWranBtn setTitle:@"历史照片" forState:UIControlStateNormal];
    imgWranBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    [imgWranBtn addTarget:self action:@selector(faceHistory) forControlEvents:UIControlEventTouchUpInside];
    [imgWranBtn setTitleEdgeInsets:UIEdgeInsetsMake(imgWranBtn.imageView.frame.size.height ,-imgWranBtn.imageView.frame.size.width, -5,0.0)];
    [imgWranBtn setImageEdgeInsets:UIEdgeInsetsMake(-10, 20,0.0, -imgWranBtn.titleLabel.bounds.size.width)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:imgWranBtn];
    
    _selTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64) style:UITableViewStylePlain];
    _selTableView.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    _selTableView.delegate = self;
    _selTableView.dataSource = self;
    _selTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.view addSubview:_selTableView];
    
    [_selTableView registerNib:[UINib nibWithNibName:@"SelPhotoCell" bundle:nil] forCellReuseIdentifier:@"SelPhotoCell"];
    [_selTableView registerNib:[UINib nibWithNibName:@"SelTimeCell" bundle:nil] forCellReuseIdentifier:@"BeginTimeCell"];
    [_selTableView registerNib:[UINib nibWithNibName:@"SelTimeCell" bundle:nil] forCellReuseIdentifier:@"EndTimeCell"];
    [_selTableView registerNib:[UINib nibWithNibName:@"SimilarValueCell" bundle:nil] forCellReuseIdentifier:@"SimilarValueCell"];
    [_selTableView registerNib:[UINib nibWithNibName:@"FaceQueryCell" bundle:nil] forCellReuseIdentifier:@"FaceQueryCell"];
    
    // 时间默认一个月
    NSDateFormatter *showFormat = [[NSDateFormatter alloc] init];
    [showFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [showFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
    _beginTimeStr = [showFormat stringFromDate:[self formatMonthDate]];
    _endTimeStr = [showFormat stringFromDate:[NSDate date]];
    
    [_selTableView reloadData];
}

#pragma mark 查询 cell 协议
- (void)faceQuery {
    
    if(_selPhotoCell.selImgView.image == nil){
        [self showHint:@"请先选择识别照片"];
        return;
    }
    
    if(_beginSelTimeCell.timeLabel.text == nil || _beginSelTimeCell.timeLabel.text.length <= 0){
        [self showHint:@"请选择开始时间"];
        return;
    }
    
    if(_endSelTimeCell.timeLabel.text == nil || _endSelTimeCell.timeLabel.text.length <= 0){
        [self showHint:@"请选择结束时间"];
        return;
    }
    
    if(_requestCode == nil || [_requestCode isKindOfClass:[NSNull class]] || ![_requestCode isEqualToString:@"1"]){
        if(_requestMsg != nil && ![_requestMsg isKindOfClass:[NSNull class]]){
            [self showHint:_requestMsg];
        }else {
            [self showHint:@"请选择人脸照片"];
        }
        return;
    }
    
    NSDateFormatter *showFormat = [[NSDateFormatter alloc] init];
    [showFormat setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    [showFormat setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *showStartDate = [showFormat dateFromString:_beginSelTimeCell.timeLabel.text];
    NSDate *showEndDate = [showFormat dateFromString:_endSelTimeCell.timeLabel.text];
    
    // 结束时间不能小于开始时间
    NSComparisonResult result = [showStartDate compare:showEndDate];
    if (result == NSOrderedDescending) {
        //end比start小
        [self showHint:@"结束时间不能小于开始时间"];
        return;
    }
    
    // 查询接口，根据图片和时间查询人脸信息。list中在更具id查询列表轨迹信息
    //    [self imageData:_selPhotoCell.selImgView.image];
    
    // 跳转查询轨迹列表
    FaceListViewController *faceListVC = [[FaceListViewController alloc] init];
    faceListVC.faceModel = _model;
    faceListVC.beginTime = _beginSelTimeCell.timeLabel.text;
    faceListVC.endTime = _endSelTimeCell.timeLabel.text;
    faceListVC.threshold = [NSNumber numberWithFloat:_similarValueCell.similarSlider.value * 100];
    faceListVC.orgImage = _selPhotoCell.selImgView.image;
    [self.navigationController pushViewController:faceListVC animated:YES];
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
    //    NSData *data = UIImageJPEGRepresentation(_selPhotoCell.selImgView.image, 1.0f);
    
    NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    encodedImageStr = [NSString stringWithFormat:@"data:image/jpeg;base64,%@", encodedImageStr];
    encodedImageStr = [encodedImageStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    encodedImageStr = [encodedImageStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/faceRecognition/imageUpload", Main_Url];
    NSMutableDictionary *param = @{}.mutableCopy;
    [param setObject:encodedImageStr forKey:@"base64EncodeImage"];
    
    // 清除上次选择图片
    _model = nil;
    _requestCode = nil;
    _requestMsg = nil;
    
    [self showHudInView:self.view hint:@"加载中"];
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        _requestCode = [NSString stringWithFormat:@"%@", responseObject[@"code"]];
        _requestMsg = [NSString stringWithFormat:@"%@", responseObject[@"message"]];
        
        if(responseObject[@"code"] != nil && ![responseObject[@"code"] isKindOfClass:[NSNull class]] && [responseObject[@"code"] isEqualToString:@"1"]){
            
            _model = [[FaceQueryModel alloc] initWithDataDic:responseObject[@"responseData"]];
            
            // 保存图片到沙盒并存储数据库
            [self saveImgToFile:selImage withId:_model.faceImageId];
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

-(void)_leftBarBtnItemClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UItableView协议
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return 1;
    }else {
        return 4;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0 && indexPath.row == 0){
        return 200;
    }else {
        return 75;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 1){
        return 12;
    }
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0 && indexPath.row == 0){
        _selPhotoCell = [tableView dequeueReusableCellWithIdentifier:@"SelPhotoCell" forIndexPath:indexPath];
        _selPhotoCell.selFaceDelegate = self;
        return _selPhotoCell;
    }else if(indexPath.section == 1 && indexPath.row == 0) {
        _beginSelTimeCell = [tableView dequeueReusableCellWithIdentifier:@"BeginTimeCell"];
        _beginSelTimeCell.titleLabel.text = @"开始时间";
        _beginSelTimeCell.timeLabel.text = _beginTimeStr;
        return _beginSelTimeCell;
    }else if(indexPath.section == 1 && indexPath.row == 1) {
        _endSelTimeCell = [tableView dequeueReusableCellWithIdentifier:@"EndTimeCell"];
        _endSelTimeCell.titleLabel.text = @"结束时间";
        _endSelTimeCell.timeLabel.text = _endTimeStr;
        return _endSelTimeCell;
    }else if(indexPath.section == 1 && indexPath.row == 2){
        _similarValueCell = [tableView dequeueReusableCellWithIdentifier:@"SimilarValueCell" forIndexPath:indexPath];
        return _similarValueCell;
    }else if(indexPath.section == 1 && indexPath.row == 3){
        _faceQueryCell = [tableView dequeueReusableCellWithIdentifier:@"FaceQueryCell" forIndexPath:indexPath];
        _faceQueryCell.faceDelegate = self;
        return _faceQueryCell;
    }else {
        return [UITableViewCell new];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 1 && (indexPath.row == 0 || indexPath.row == 1)){
        WSDatePickerView *datepicker = [[WSDatePickerView alloc] initWithDateStyle:DateStyleShowYearMonthDayHourMinute scrollToDate:[NSDate date] CompleteBlock:^(NSDate *selectDate) {
            NSString *date = [selectDate stringWithFormat:@"yyyy-MM-dd HH:mm"];
            if(indexPath.row == 0){
                _beginTimeStr = date;
                _beginSelTimeCell.timeLabel.text = date;
            }else if(indexPath.row == 1){
                _endTimeStr = date;
                _endSelTimeCell.timeLabel.text = date;
            }
            
        }];
        datepicker.dateLabelColor = [UIColor colorWithHexString:@"1B82D1"];//年-月-日-时-分 颜色
        datepicker.datePickerColor = [UIColor blackColor];//滚轮日期颜色
        datepicker.doneButtonColor = [UIColor colorWithHexString:@"1B82D1"];//确定按钮的颜色
        datepicker.yearLabelColor = [UIColor clearColor];//大号年份字体颜色
        datepicker.maxLimitDate = [NSDate date];
        [datepicker show];
    }
}

#pragma mark 选择人脸图片协议
- (void)selFacePhoto {
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingGif = NO;
    
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        _selPhotoCell.selImgView.image = photos.firstObject;
        _selPhotoCell.selImgView.backgroundColor = [UIColor whiteColor];
        _selPhotoCell.msgLabel.text = @"更换照片";
        
        // 判断图片是否存在头像
        [self imageData:photos.firstObject];
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}
- (void)faceHistory {
    FaceHistoryViewController *hisVC = [[FaceHistoryViewController alloc] init];
    hisVC.selHistoryImgDelegate = self;
    [self.navigationController pushViewController:hisVC animated:YES];
}

// 保存图片到沙盒
- (void)saveImgToFile:(UIImage *)image withId:(NSString *)faceImgId {
    NSString *imageName;
    if(faceImgId != nil && ![faceImgId isKindOfClass:[NSNull class]]){
        imageName = [NSString stringWithFormat:@"%@.jpg", faceImgId];
    }else {
        imageName = [NSString stringWithFormat:@"%@.jpg", [self getNowTimeTimestamp2]];
    }
    NSString *imagePath = [NSString stringWithFormat:@"%@%@", FaceHistoryPath, imageName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    // 文件是否存在
    if([fileManager fileExistsAtPath:FaceHistoryPath]){
        [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:NO];
    }else {
        NSError *createError = nil;
        [fileManager createDirectoryAtPath:FaceHistoryPath withIntermediateDirectories:YES attributes:nil error:&createError];
        if(createError == nil){
            [UIImagePNGRepresentation(image) writeToFile:imagePath atomically:NO];
        }
    }
    
    [self saveHistoryImg:imageName];
}
// 获取当前时间戳
- (NSString *)getNowTimeTimestamp2 {
    NSDate *dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%0.f", a*1000];//转为字符型
    return timeString;
}

// 保存记录到数据库
- (void)saveHistoryImg:(NSString *)imgPath {
    FaceCoreDataManager *managed = [FaceCoreDataManager shareManager];
    // 保存
    FaceImgHistory *faceImg = [managed createMO:@"FaceImgHistory"];
    faceImg.selTime = [NSDate date];
//    faceImg.selTime = [self formatMonthDate];
    faceImg.imgFilePath = imgPath;
    
    [managed save:faceImg];
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

#pragma mark 选择历史照片协议
- (void)selHistoryImg:(FaceImgHistory *)faceImgHistory {
    UIImage *selImg = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@%@", FaceHistoryPath, faceImgHistory.imgFilePath]];
    [self imageData:selImg];
    
    _selPhotoCell.selImgView.image = selImg;
}

@end
