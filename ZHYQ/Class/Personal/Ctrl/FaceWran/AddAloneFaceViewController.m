//
//  AddAloneFaceViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/24.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "AddAloneFaceViewController.h"
#import "UIImage+Zip.h"

@interface AddAloneFaceViewController ()<TZImagePickerControllerDelegate>
{
    __weak IBOutlet UIImageView *_faceImgView;
    __weak IBOutlet UIButton *_changeFaceBt;
    __weak IBOutlet UITextField *_nameTF;
    
    __weak IBOutlet UIButton *_certainBt;
}
@end

@implementation AddAloneFaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
    
    UITapGestureRecognizer *editEndTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEdit)];
    [self.view addGestureRecognizer:editEndTap];
}
- (void)endEdit {
    [self.view endEditing:YES];
}

- (void)_initView {
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#EFEFEF"];
    
    _certainBt.layer.cornerRadius = 4;
    _certainBt.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
    _certainBt.layer.borderWidth = 1;
    
    if(_isAdd){
        self.title = @"新增人像";
        [_certainBt setTitle:@"确认新增" forState:UIControlStateNormal];
    }else {
        self.title = @"修改人像";
        [_certainBt setTitle:@"确认修改" forState:UIControlStateNormal];
    }
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    if(_isAdd && _selImg){
        _faceImgView.image = _selImg;
    }else if(_faceWranModel != nil && _faceWranModel.faceImageBase64 != nil && ![_faceWranModel.faceImageBase64 isKindOfClass:[NSNull class]]){
        NSString *base64Str = [_faceWranModel.faceImageBase64 componentsSeparatedByString:@"base64,"].lastObject;
        NSData *decodedImageData = [[NSData alloc] initWithBase64EncodedString:base64Str options:NSDataBase64DecodingIgnoreUnknownCharacters];
        UIImage *decodedImage = [UIImage imageWithData:decodedImageData];
        _faceImgView.image = decodedImage;
        
        _nameTF.text = [NSString stringWithFormat:@"%@", _faceWranModel.name];
    }
    
    _faceImgView.backgroundColor = [UIColor colorWithHexString:@"f2f2f2"];
    _faceImgView.contentMode = UIViewContentModeScaleAspectFit;
}

-(void)_leftBarBtnItemClick:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)changeFace:(id)sender {
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingGif = NO;
    
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        if(photos.count > 0){
            _faceImgView.image = photos.firstObject;
        }
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}
- (IBAction)certainAction:(id)sender {
    if(_faceImgView.image == nil){
        [self showHint:@"请选择人像图片"];
        return;
    }
    if(_nameTF.text == nil || _nameTF.text.length <= 0){
        [self showHint:@"请输入姓名"];
        return;
    }
    
    NSString *urlStr;
    if(_isAdd){
        urlStr = [NSString stringWithFormat:@"%@/faceRecognition/addAlarmIamges", Main_Url];
    }else {
        urlStr = [NSString stringWithFormat:@"%@/faceRecognition/updateAlarmIamges", Main_Url];
    }
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:_nameTF.text forKey:@"name"];
    [paramDic setObject:@"19" forKey:@"repositoryId"];
    if(!_isAdd && _faceWranModel != nil){
        [paramDic setObject:_faceWranModel.face_image_id forKey:@"faceImageId"];
    }
    [paramDic setObject:[self imgToBase64Str:_faceImgView.image] forKey:@"base64EncodeImage"];
    
    NSString *paramStr = [Utils convertToJsonData:paramDic];
    NSDictionary *params = @{@"param":paramStr};
    
    [self showHudInView:self.view hint:@""];
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        
        NSString *code = responseObject[@"code"];
        if (code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]) {
            FaceWranModel *model;
            if(_isAdd){
                model = [[FaceWranModel alloc] initWithDataDic:responseObject[@"responseData"]];
                model.name = _nameTF.text;
            }else {
                _faceWranModel.name = _nameTF.text;
                _faceWranModel.faceImageBase64 = [self imgToBase64Str:_faceImgView.image];
                model = _faceWranModel;
            }
            
            if(_faceCompleteDelegate != nil && [_faceCompleteDelegate respondsToSelector:@selector(faceComplete:withIsAdd:)]){
                [_faceCompleteDelegate faceComplete:model withIsAdd:_isAdd];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
            [self showHint:responseObject[@"message"]];
        }
        
    } failure:^(NSError *error) {
        [self hideHud];
        [self showHint:KRequestFailMsg];
    }];
}

#pragma mark UITableView协议
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 0){
        return 0.1;
    }else {
        return 5;
    }
}

- (NSString *)imgToBase64Str:(UIImage *)image {
    NSData *data = [UIImage compressWithOrgImg:image];
    
    NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    encodedImageStr = [NSString stringWithFormat:@"data:image/jpeg;base64,%@", encodedImageStr];
    encodedImageStr = [encodedImageStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    encodedImageStr = [encodedImageStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return encodedImageStr;
}

@end
