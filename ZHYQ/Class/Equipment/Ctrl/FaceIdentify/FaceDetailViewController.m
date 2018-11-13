//
//  FaceDetailViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/3/29.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "FaceDetailViewController.h"

@interface FaceDetailViewController ()
{
    
    __weak IBOutlet UIImageView *_faceImgView;
    __weak IBOutlet UILabel *_simlarLabel;
    __weak IBOutlet UIImageView *_traceImgView;
    
    
    __weak IBOutlet UILabel *_sexLabel;
    __weak IBOutlet UILabel *_ageLabel;
    __weak IBOutlet UILabel *_glassesLabel;
    __weak IBOutlet UILabel *_camearLabel;
    __weak IBOutlet UILabel *_locationLabel;
    
    __weak IBOutlet UIImageView *_orgImgView;
    
}
@end

@implementation FaceDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
}

- (void)_initView {
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    
    _faceImgView.layer.cornerRadius = _faceImgView.width/2;
    _traceImgView.layer.cornerRadius = _faceImgView.width/2;
    
    _orgImgView.layer.borderColor = [UIColor blackColor].CGColor;
    _orgImgView.layer.borderWidth = 0.8;
    
    // 图片填充模式
    _faceImgView.contentMode = UIViewContentModeScaleAspectFit;
    _traceImgView.contentMode = UIViewContentModeScaleAspectFit;
    _orgImgView.contentMode = UIViewContentModeScaleAspectFit;
    
    // 上传图片人脸
    NSString *faceBase64Str = [_faceBase64 componentsSeparatedByString:@"base64,"].lastObject;
    NSData *faceImageData = [[NSData alloc] initWithBase64EncodedString:faceBase64Str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *faceImage = [UIImage imageWithData:faceImageData];
    
    _faceImgView.image = faceImage;
    
    // 匹配度
    _simlarLabel.text = [NSString stringWithFormat:@"%.0f", _faceListModel.similarity.floatValue];
    
    // 轨迹人脸
    NSString *traceBase64Str = [_faceListModel.faceImageBase64 componentsSeparatedByString:@"base64,"].lastObject;
    NSData *traceImageData = [[NSData alloc] initWithBase64EncodedString:traceBase64Str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *traceImage = [UIImage imageWithData:traceImageData];
    
    _traceImgView.image = traceImage;
    
    // 性别
    if(_faceListModel.rec_gender.integerValue == 1){
        _sexLabel.text = @"男";
    }else {
        _sexLabel.text = @"女";
    }
    
    // 年龄
    if(_faceListModel.rec_age_range.integerValue == 0){
        _ageLabel.text = @"少年";
    }else if(_faceListModel.rec_age_range.integerValue == 1){
        _ageLabel.text = @"青年";
    }else if(_faceListModel.rec_age_range.integerValue == 2){
        _ageLabel.text = @"中年";
    }else {
        _sexLabel.text = @"老年";
    }
    
    // 是否眼镜
    if(_faceListModel.rec_glasses.integerValue == 0){
        _glassesLabel.text = @"无";
    }else {
        _glassesLabel.text = @"有";
    }
    
    // 人脸相机id
    _camearLabel.text = [NSString stringWithFormat:@"%@", _faceListModel.repository_address];
    
    // 人脸相机位置
    _locationLabel.text = _faceListModel.repository_name;
    
    // 上传原图
//    _orgImgView.image = _orgImage;
    [self orgImgView];
}

- (void)orgImgView {
    NSString *urlStr = [NSString stringWithFormat:@"%@/faceRecognition/getImage", Main_Url];
    NSMutableDictionary *param = @{}.mutableCopy;
    [param setObject:_faceListModel.picture_uri forKey:@"imgUrl"];
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        if([responseObject[@"code"] isEqualToString:@"1"]){
            NSString *imgBase64 = responseObject[@"responseData"][@"imgBase64"];
            NSString *faceBase64Str = [imgBase64 componentsSeparatedByString:@"base64,"].lastObject;
            NSData *faceImageData = [[NSData alloc] initWithBase64EncodedString:faceBase64Str options:NSDataBase64DecodingIgnoreUnknownCharacters];
            UIImage *faceImage = [UIImage imageWithData:faceImageData];
            
            _orgImgView.image = faceImage;
        }
    } failure:^(NSError *error) {
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)_closeAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
