//
//  IllegalPhotoViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/8.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "IllegalPhotoViewController.h"
#import "InputKeyBoardView.h"
#import "NumInputView.h"
#import "UIImage+Zip.h"
#import "UITextField+Position.h"

@interface IllegalPhotoViewController ()<TZImagePickerControllerDelegate,UITextFieldDelegate ,UITextViewDelegate>
{
    
    __weak IBOutlet UITextField *_licenseTextField;
    
    __weak IBOutlet UILabel *_hitMsgLabel;
    __weak IBOutlet UITextView *_areaTextView;
    
    __weak IBOutlet UIButton *_takePhotoBtn;
    
    NSMutableArray *_imageDataSource;
    
    __weak IBOutlet UIImageView *photoView;
    
    __weak IBOutlet UILabel *signLab;
    
    InputKeyBoardView *_keyBoardView;
    NumInputView *_numInputView;
}

@end

@implementation IllegalPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    
    [self configUI];
    
    [self _initKeyBoradInput];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commitBtnClick) name:@"IllegalCommit" object:nil];
}

-(void)configUI
{
    
    UITapGestureRecognizer *viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewAction)];
    [self.view addGestureRecognizer:viewTap];
    
    photoView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_takeaPhotoBtnClick:)];
    [photoView addGestureRecognizer:tap];
    
    _licenseTextField.delegate = self;
    _areaTextView.delegate = self;
}
- (void)viewAction {
    [self.view endEditing:YES];
}

#pragma mark 设置自定义键盘
- (void)_initKeyBoradInput {
    int verticalCount = 5;
    CGFloat kheight = KScreenWidth/10 + 8;
    _keyBoardView = [[InputKeyBoardView alloc] initWithFrame:CGRectMake(0, KScreenHeight - kheight * verticalCount, KScreenWidth, kheight * verticalCount) withClickKeyBoard:^(NSString *character) {
        
        NSString *textStr = [_licenseTextField.text stringByAppendingString:character];
        if(textStr.length <= 8){
            [self judgementKeyBorad:textStr];
            [_licenseTextField positionAddCharacter:character];
        }
        
    } withDelete:^{
        if(_licenseTextField.text.length > 0){
            // 删除光标位置字符
            [_licenseTextField positionDelete];

            [self judgementKeyBorad:_licenseTextField.text];
        }
    } withConfirm:^{
        [self.view endEditing:YES];
    } withCut:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            _licenseTextField.inputView = _numInputView;
            [_licenseTextField reloadInputViews];
        });
    }];
    [_keyBoardView setNeedsDisplay];
    _licenseTextField.inputView = _keyBoardView;
    
    _numInputView = [[NumInputView alloc] initWithFrame:CGRectMake(0, KScreenHeight - kheight * verticalCount, KScreenWidth, kheight * verticalCount) withClickKeyBoard:^(NSString *character) {
        
        NSString *textStr = [_licenseTextField.text stringByAppendingString:character];
        if(textStr.length <= 8){
            [self judgementKeyBorad:textStr];
            [_licenseTextField positionAddCharacter:character];
        }
        
    } withDelete:^{
        // 依次删除
        if(_licenseTextField.text.length > 0){
            // 删除光标位置字符
            [_licenseTextField positionDelete];
            [self judgementKeyBorad:_licenseTextField.text];
        }
    } withConfirm:^{
        [self.view endEditing:YES];
    } withCut:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            _licenseTextField.inputView = _keyBoardView;
            [_licenseTextField reloadInputViews];
        });
    }];
    [_numInputView setNeedsDisplay];
    
}

- (void)judgementKeyBorad:(NSString *)textStr {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(textStr.length > 0){
            _licenseTextField.inputView = _numInputView;
            [_licenseTextField reloadInputViews];
        }else{
            _licenseTextField.inputView = _keyBoardView;
            [_licenseTextField reloadInputViews];
        }
    });
}

- (IBAction)_takeaPhotoBtnClick:(id)sender {
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        [_imageDataSource removeLastObject];
        [_imageDataSource addObjectsFromArray:photos];
        
        photoView.image = photos.firstObject;
        
        _takePhotoBtn.hidden = YES;
        signLab.hidden = YES;
        
        //
        NSData *data = [UIImage compressWithOrgImg:photos.firstObject];
        photoView.image = [UIImage imageWithData:data];
        
        [self photoCarNo:photoView.image];
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];

}
#pragma mark 选择车牌
- (IBAction)selCarNoImg {
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        [_imageDataSource removeLastObject];
        [_imageDataSource addObjectsFromArray:photos];
        
        [self photoCarNo:photos.firstObject];
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark 车牌识别接口
- (void)photoCarNo:(UIImage *)carNoImg {
    NSData *data = [UIImage compressWithOrgImg:carNoImg];
    NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    encodedImageStr = [NSString stringWithFormat:@"data:image/jpeg;base64,%@", encodedImageStr];
    encodedImageStr = [encodedImageStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    encodedImageStr = [encodedImageStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/parking/carPlateRecognition", Main_Url];
    NSDictionary *paramDic = @{@"imgBase64":encodedImageStr};
    NSString *jsonStr = [Utils convertToJsonData:paramDic];
    NSDictionary *param = @{@"param":jsonStr};
    
    // 清除上次选择图片
    [self showHudInView:self.view hint:@"加载中"];
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        if(responseObject[@"code"] != nil && ![responseObject[@"code"] isKindOfClass:[NSNull class]] && [responseObject[@"code"] isEqualToString:@"1"]){
            NSString *carNo = responseObject[@"responseData"][@"number"];
            _licenseTextField.text = [NSString stringWithFormat:@"%@", carNo];
            
            NSString *color = [NSString stringWithFormat:@"%@", responseObject[@"responseData"][@"color"]];
            NSString *colorStr = [self colorNumToColorString:color];
//            _areaTextView.text = [NSString stringWithFormat:@"%@ 车牌颜色(%@)", _areaTextView.text, colorStr];
            
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


- (void)commitBtnClick {
    [self.view endEditing:YES];
    
    if(_licenseTextField.text == nil || _licenseTextField.text.length <=0 ){
        [self showHint:@"请填写违停车牌"];
        return;
    }
    if(_areaTextView.text == nil || _areaTextView.text.length <=0 ){
        [self showHint:@"请填写违停说明"];
        return;
    }
    if(_areaTextView.text.length < 6 ){
        [self showHint:@"违停说明不能少于6个字"];
        return;
    }
    if(photoView.image == nil) {
        [self showHint:@"请拍摄违停照片"];
        return;
    }
    
    [self showHudInView:self.view hint:@""];
    // 图片上传
    NSString *urlStr = [NSString stringWithFormat:@"%@/fileProcess/uploadPeccancyImg", ParkMain_Url];
    [[NetworkClient sharedInstance] UPLOAD:urlStr dict:nil imageArray:@[photoView.image] progressFloat:^(float progressFloat) {
        NSLog(@"%f", progressFloat);
    } succeed:^(id responseObject) {
        if([responseObject[@"success"] boolValue]){
            [self commint:responseObject[@"data"][@"imgUrl"]];
        }else {
            [self hideHud];
        }
    } failure:^(NSError *error) {
        [self hideHud];
        NSLog(@"%@", error);
    }];

}

-(void)commint:(NSString *)imgUrl {
    NSString *urlStr = [NSString stringWithFormat:@"%@/operaIllegal/illegal",ParkMain_Url];
    
    NSMutableDictionary *params = @{}.mutableCopy;
    [params setObject:_areaTextView.text forKey:@"content"];
    [params setObject:_licenseTextField.text forKey:@"carno"];
    [params setObject:KParkId forKey:@"parkId"];
    [params setObject:[kUserDefaults objectForKey:KLoginUserName] forKey:@"memberName"];
    if(imgUrl != nil && ![imgUrl isKindOfClass:[NSNull class]]){
        [params setObject:imgUrl forKey:@"picUrl"];
    }
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        if([responseObject[@"success"] boolValue]){
            _areaTextView.text = @"";
            _hitMsgLabel.hidden = NO;
            _licenseTextField.text = @"";
            photoView.image = [UIImage imageNamed:@""];
            _takePhotoBtn.hidden = NO;
            signLab.hidden = NO;
            
            // 上报成功
            [self logRecord];   // 记录日志
            
            self.tabBarController.selectedIndex = 1;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshIllegaList" object:nil];
        }
        [self showHint:responseObject[@"message"]];
    } failure:^(NSError *error) {
        [self hideHud];
    }];
}

#pragma mark UITableView协议
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 8;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)logRecord {
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:@"违停记录上报" forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:@"operaIllegal/illegal" forKey:@"operateUrl"];//操作url
    [logDic setObject:@"违停记录上报" forKey:@"operateDes"];//操作描述 说明
//    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
//    [logDic setObject:<#(nonnull id)#> forKey:@"operateValue"];//操作值(如音量大小)
//    [logDic setObject:<#(nonnull id)#> forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"停车" forKey:@"operateDeviceName"];//操作设备名 模块
//    [logDic setObject:<#(nonnull id)#> forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}

- (NSString *)colorNumToColorString:(NSString *)colorNum {
    /*
     blue：蓝色
     yellow：黄色
     green：绿色
     */
    NSString *colorStr = @"";
    if(colorNum != nil && ![colorNum isKindOfClass:[NSNull class]]){
        if([colorNum isEqualToString:@"blue"]){
            colorStr = @"蓝色";
        }else if([colorNum isEqualToString:@"yellow"]){
            colorStr = @"黄色";
        }else if([colorNum isEqualToString:@"green"]){
            colorStr = @"绿色";
        }
    }
    return colorStr;
}

#pragma mark UITextField协议
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if(textField == _licenseTextField){
        [UIView animateWithDuration:0.3 animations:^{
            [self.tableView setContentOffset:CGPointMake(0, 100) animated:NO];
        }];
    }
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
//    [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
}

#pragma mark UITextView协议
- (void)textViewDidBeginEditing:(UITextView *)textView {
    if(textView == _areaTextView){
        [UIView animateWithDuration:0.3 animations:^{
            [self.tableView setContentOffset:CGPointMake(0, 170) animated:NO];
        }];
    }
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *tvString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if(tvString.length <= 0){
        _hitMsgLabel.hidden = NO;
    }else {
        _hitMsgLabel.hidden = YES;
    }
    
    return YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"IllegalCommit" object:nil];
}

@end
