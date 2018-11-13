//
//  CompleteConfirmViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/5/16.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "CompleteConfirmViewController.h"
#import "WorkListCenViewController.h"

@interface CompleteConfirmViewController ()<UITextViewDelegate, TZImagePickerControllerDelegate>
{
    __weak IBOutlet UIImageView *_photoImgView;
    
    __weak IBOutlet UITextView *_remarkTV;
    UILabel *_tvMsgLabel;
    
    __weak IBOutlet UIView *_bottpmView;
    __weak IBOutlet UIButton *_completeBt;
}
@end

@implementation CompleteConfirmViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
}

- (void)_initView {
    self.title = @"完成反馈";
    
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    _bottpmView.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _completeBt.layer.cornerRadius = 4;
    _completeBt.layer.borderWidth = 1;
    _completeBt.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
    
    _remarkTV.delegate = self;
    
    // textView提示label
    _tvMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 9, _remarkTV.width - 4, 17)];
    _tvMsgLabel.text = @"请填写完成备注";
    _tvMsgLabel.textColor = [UIColor colorWithHexString:@"#c7c7cd"];
    _tvMsgLabel.font = [UIFont systemFontOfSize:17];
    _tvMsgLabel.textAlignment = NSTextAlignmentLeft;
    [_remarkTV addSubview:_tvMsgLabel];
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)confirmComplete:(id)sender {
    if(_photoImgView.image == nil){
        [self showHint:@"请添加修好设备的现场照片"];
        return;
    }
    if(_remarkTV.text == nil || _remarkTV.text.length <= 0){
        [self showHint:@"请填写完成备注"];
        return;
    }
    
    // 先上传维修好的图片
    [self _uploadImage];
}

- (void)_uploadImage {
    [self showHudInView:self.view hint:@""];
    NSString *urlStr = [NSString stringWithFormat:@"%@/common/custImageUpload",Main_Url];
    
    [[NetworkClient sharedInstance] UPLOAD:urlStr dict:nil imageArray:@[_photoImgView.image] progressFloat:^(float progressFloat) {
        
    } succeed:^(id responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *dic = responseObject[@"responseData"];
            NSString *imgUrl = dic[@"url"];
            
            [self completeBill:imgUrl];
        }
    } failure:^(NSError *error) {
        [self hideHud];
    }];
}
// 维修完成
- (void)completeBill:(NSString *)imgUrl {
    NSString *urlStr = [NSString stringWithFormat:@"%@/deviceAlarm/dealOrder", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:_billListModel.orderId forKey:@"orderId"];

    if(_billListModel.deviceId != nil && ![_billListModel.deviceId isKindOfClass:[NSNull class]]){
        [paramDic setObject:_billListModel.deviceId forKey:@"deviceId"];
    }
    if(_billListModel.deviceName != nil && ![_billListModel.deviceName isKindOfClass:[NSNull class]]){
        [paramDic setObject:_billListModel.deviceName forKey:@"deviceName"];
    }
    [paramDic setObject:imgUrl forKey:@"handleImage"];
    [paramDic setObject:_remarkTV.text forKey:@"remark"];
     
    NSString *jsonStr = [Utils convertToJsonData:paramDic];
    NSDictionary *param = @{@"param":jsonStr};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            // 确认完成 成功
            [self popWithListVC];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"BillRepairsComplete" object:nil userInfo:@{@"orderId":_billListModel.orderId}];
        }
        NSString *message = responseObject[@"message"];
        if(message != nil && ![message isKindOfClass:[NSNull class]]){
            [self showHint:message];
        }
    } failure:^(NSError *error) {
        [self hideHud];
        [self showHint:KRequestFailMsg];
    }];
}
- (void)popWithListVC {
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[WorkListCenViewController class]]) {
            WorkListCenViewController *vc = (WorkListCenViewController *)controller;
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}

#pragma mark UItable 协议
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 0){
        return 0.1;
    }else {
        return 5;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        // 选择照片
        TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
        
        // 你可以通过block或者代理，来得到用户选择的照片.
        [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
            _photoImgView.backgroundColor = [UIColor whiteColor];
            _photoImgView.contentMode = UIViewContentModeScaleAspectFit;
            _photoImgView.clipsToBounds = YES;
            _photoImgView.image = photos.firstObject;
            
        }];
        [self presentViewController:imagePickerVc animated:YES completion:nil];

    }
}

#pragma mark UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *tvString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    if(tvString.length <= 0){
        _tvMsgLabel.hidden = NO;
    }else {
        _tvMsgLabel.hidden = YES;
    }
    
    return YES;
}

@end
