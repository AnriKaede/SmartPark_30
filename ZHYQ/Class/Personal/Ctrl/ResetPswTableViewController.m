//
//  ResetPswTableViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/13.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "ResetPswTableViewController.h"
#import "MD5.h"

@interface ResetPswTableViewController ()
{
    __weak IBOutlet UITextField *_usernameTF;
    
    __weak IBOutlet UITextField *_oldPswTF;
    
    __weak IBOutlet UITextField *_newPswTF;
    __weak IBOutlet UITextField *_cerPswTF;
    
}
@end

@implementation ResetPswTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
}
- (void)_initView {
    
    self.title = @"修改密码";
    
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    
    if(_isOverdue){
        // 禁止左滑
        id traget = self.navigationController.interactivePopGestureRecognizer.delegate;
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:traget action:nil];
        [self.view addGestureRecognizer:pan];
    }
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveAction)];
    
    // 固定用户名为登录保存的用户名
    _usernameTF.text = [[NSUserDefaults standardUserDefaults] objectForKey:KLoginUserName];
    _usernameTF.enabled = NO;
    
}

- (void)_leftBarBtnItemClick {
    if(_isOverdue){
        [self dontChange];
        [self dismissViewControllerAnimated:YES completion:nil];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)dontChange {
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:KAdminUserId];
    NSString *urlStr = [NSString stringWithFormat:@"%@/public/upManegePwdTime?userId=%@", Main_Url, userId];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        NSLog(@"%@", responseObject);
    } failure:^(NSError *error) {
    }];
}

- (void)saveAction {
    [self.view endEditing:YES];
    
    if(_usernameTF.text == nil || _usernameTF.text.length <= 0){
        [self showHint:@"请输入账户名"];
        return;
    }
    if(_oldPswTF.text == nil || _oldPswTF.text.length <= 0){
        [self showHint:@"请输入旧密码"];
        return;
    }
    if(_newPswTF.text == nil || _newPswTF.text.length <= 0){
        [self showHint:@"请输入新密码"];
        return;
    }
    if(_cerPswTF.text == nil || _cerPswTF.text.length <= 0){
        [self showHint:@"请输入确认密码"];
        return;
    }
    if(![_newPswTF.text isEqualToString:_cerPswTF.text]){
        [self showHint:@"两次密码输入不一次"];
        return;
    }
    
    // 判断新密码是否满足字母加数字 8位
    if(![Utils judgePassWordLegal:_newPswTF.text]){
        [Utils alertTitle:@"提示" message:@"您的新密码必选包括字母和数字，密码长度至少8位" delegate:nil cancelBtn:@"确定" otherBtnName:nil];
        return;
    }
    
    // 旧密码和新密码不能一样
    if([_oldPswTF.text isEqualToString:_newPswTF.text]){
        [self showHint:@"新密码和旧密码不能一样"];
        return;
    }
    
    NSString *resetUrl = [NSString stringWithFormat:@"%@/common/upPwd", Main_Url];
    NSMutableDictionary *params = @{}.mutableCopy;
    [params setObject:_usernameTF.text forKey:@"loginName"];
    [params setObject:[MD5 md5:_oldPswTF.text] forKey:@"oldPwd"];
    [params setObject:[MD5 md5:_newPswTF.text] forKey:@"newPwd"];
    
    [self showHudInView:self.view hint:@""];
    [[NetworkClient sharedInstance] GET:resetUrl dict:params progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        BOOL isOk = NO;
        if([responseObject[@"code"] isEqualToString:@"1"]){
            isOk = YES;
        }
        [self showAlert:responseObject[@"message"] isOK:isOk];
        
    } failure:^(NSError *error) {
        [self hideHud];
        [self showHint:KRequestFailMsg];
    }];
    
}

- (void)showAlert:(NSString *)message isOK:(BOOL)isOk {
    UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if(isOk){
            if(_isOverdue){
                [self dismissViewControllerAnimated:YES completion:nil];
            }else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }];
    [alertCon addAction:okAction];
    
    [self presentViewController:alertCon animated:YES completion:^{
    }];
}

@end
