//
//  LEDScreenShotViewController.m
//  ZHYQ
//
//  Created by coder on 2018/10/23.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "LEDScreenShotViewController.h"
#import "UIImage+Zip.h"

@interface LEDScreenShotViewController ()
{
    UIView *bgView;
    NSInteger index;
    UIButton *saveScreenBtn;
    UIButton *reScreenBtn;
}

@property (nonatomic,retain) UIImageView *imageView;
//截图时间
@property (nonatomic,retain) UILabel *screenTimeLab;

@end

@implementation LEDScreenShotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    index = 1;
    
    [self initNav];
    
    [self initView];
    
    [self loadImgData];
}

-(void)initNav{
    self.title = @"LED屏";
    if(_isStreetLight){
        if(_subDeviceModel != nil){
            self.title = [NSString stringWithFormat:@"%@", _subDeviceModel.DEVICE_NAME];
        }else if(_ledListModel != nil){
            self.title = [NSString stringWithFormat:@"%@", _ledListModel.deviceName];
        }
    }else {
        self.title = [NSString stringWithFormat:@"%@", _ledListModel.deviceName];
    }
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)initView
{
//    UIImage *image = [UIImage imageNamed:@"screen"];
//    image = [UIImage imageCompressForWidthScale:image targetWidth:KScreenWidth];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (KScreenHeight - kTopHeight - 260)/2 - 60, KScreenWidth, 260)];
//    self.imageView.image = image;
    self.imageView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.imageView];
    self.imageView.backgroundColor = [UIColor colorWithHexString:@"#f2f2f2"];
//    self.imageView.center = CGPointMake(KScreenWidth/2, 123*hScale + image.size.height/2);
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(KScreenWidth - 200, self.imageView.bottom + 20, 190, 16)];
    lab.font = [UIFont systemFontOfSize:14];
    lab.textAlignment = NSTextAlignmentRight;
    lab.textColor = [UIColor colorWithHexString:@"#E2E2E2"];
    [self.view addSubview:lab];
    self.screenTimeLab = lab;
//    self.screenTimeLab.text = @"2018-08-11 00:00:00 截图";
    
    NSDateFormatter *dateFormater = [[NSDateFormatter alloc] init];
    [dateFormater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [dateFormater stringFromDate:[NSDate date]];
    self.screenTimeLab.text = dateStr;
    
    bgView = [[UIView alloc] initWithFrame:self.view.frame];
    bgView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:bgView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [bgView addGestureRecognizer:tap];
    
    saveScreenBtn = [[UIButton alloc] initWithFrame:CGRectMake((KScreenWidth/2)*0.55-(150/2), self.view.frame.size.height-200*hScale, 150, 50)];
    [saveScreenBtn setTitle:@"保存截图" forState:UIControlStateNormal];
    saveScreenBtn.layer.cornerRadius = 4;
    saveScreenBtn.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
    saveScreenBtn.layer.borderWidth = 0.5;
    [saveScreenBtn setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
    [saveScreenBtn setImage:[UIImage imageNamed:@"led_saveScreen"] forState:UIControlStateNormal];
    [saveScreenBtn addTarget:self action:@selector(saveImg) forControlEvents:UIControlEventTouchUpInside];
    [bgView addSubview:saveScreenBtn];
    
    reScreenBtn = [[UIButton alloc] initWithFrame:CGRectMake((KScreenWidth/2)*1.45-(150/2), self.view.frame.size.height-200*hScale, 150, 50)];
    [reScreenBtn setTitle:@"重新截图" forState:UIControlStateNormal];
    reScreenBtn.layer.cornerRadius = 4;
    reScreenBtn.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
    reScreenBtn.layer.borderWidth = 0.5;
    [reScreenBtn setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
    [reScreenBtn setImage:[UIImage imageNamed:@"led_rescreen"] forState:UIControlStateNormal];
    [bgView addSubview:reScreenBtn];
    [reScreenBtn addTarget:self action:@selector(refreshImg) forControlEvents:UIControlEventTouchUpInside];
}

-(void)tapAction
{
    if (index % 2 == 1) {
        saveScreenBtn.hidden = YES;
        reScreenBtn.hidden = YES;
    }else{
        saveScreenBtn.hidden = NO;
        reScreenBtn.hidden = NO;
    }
    index++;
}

- (void)saveImg {
    if(self.imageView.image != nil){
//        UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), <#void * _Nullable contextInfo#>)
        UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
    }
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if(error == nil){
        [self showHint:@"保存成功"];
    }
}

- (void)refreshImg {
    [self loadImgData];
}

#pragma mark 请求数据
- (void)loadImgData {
    if(_isStreetLight){
        [self streetScreen];
    }else {
        [self diningHallScreen];
    }
}

- (void)diningHallScreen {
    NSString *urlStr = [NSString stringWithFormat:@"%@/udpController/sendMsgToUdpSer",Main_Url];
    
    NSMutableDictionary *searchParam = @{}.mutableCopy;
    if(_ledListModel.deviceId != nil && ![_ledListModel.deviceId isKindOfClass:[NSNull class]]){
        [searchParam setObject:_ledListModel.deviceId forKey:@"deviceId"];
    }
    [searchParam setObject:@"NOWPLAYPIC" forKey:@"instructions"];
    
    //    NSString *jsonStr = [Utils convertToJsonData:searchParam];
    //    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:searchParam progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSString *imgUrl = responseObject[@"responseData"][@"resMsg"];
            if(imgUrl != nil && ![imgUrl isKindOfClass:[NSNull class]]){
                //                [self.imageView sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
                
                dispatch_queue_t queue2 = dispatch_queue_create("Queue2", DISPATCH_QUEUE_CONCURRENT);
                dispatch_async(queue2, ^{
                    NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgUrl]];
                    UIImage *img = [UIImage imageWithData:imgData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.imageView.image = img;
                    });
                });
            }
            
        }else {
            if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
                [self showHint:responseObject[@"message"]];
            }
        }
        
    } failure:^(NSError *error) {
        
    }];
}

- (void)streetScreen {
    NSString *urlStr = [NSString stringWithFormat:@"%@/roadLamp/getPicture",Main_Url];
    
    NSMutableDictionary *searchParam = @{}.mutableCopy;
    if(_subDeviceModel != nil){
        if(_subDeviceModel.TAGID != nil && ![_subDeviceModel.TAGID isKindOfClass:[NSNull class]]){
            [searchParam setObject:_subDeviceModel.TAGID forKey:@"tagId"];
        }
    }else if(_ledListModel != nil){
        if(_ledListModel.tagid != nil && ![_ledListModel.tagid isKindOfClass:[NSNull class]]){
            [searchParam setObject:_ledListModel.tagid forKey:@"tagId"];
        }
    }
//    [searchParam setObject:@100 forKey:@"arg1"];
//    [searchParam setObject:@100 forKey:@"arg2"];
    
    NSString *jsonStr = [Utils convertToJsonData:searchParam];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSString *imageBase64 = responseObject[@"responseData"][@"imageBase64"];
            if(imageBase64 != nil && ![imageBase64 isKindOfClass:[NSNull class]]){
                NSString *traceBase64Str = [imageBase64 componentsSeparatedByString:@"base64,"].lastObject;
                NSData *traceImageData = [[NSData alloc] initWithBase64EncodedString:traceBase64Str options:NSDataBase64DecodingIgnoreUnknownCharacters];
                UIImage *traceImage = [UIImage imageWithData:traceImageData];
                self.imageView.image = traceImage;
            }
            
        }else {
            if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
                [self showHint:responseObject[@"message"]];
            }
        }
        
    } failure:^(NSError *error) {
        
    }];
}

@end
