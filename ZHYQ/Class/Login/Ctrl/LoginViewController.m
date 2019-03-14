//
//  LoginViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/22.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "LoginViewController.h"
#import <Hyphenate/Hyphenate.h>

@interface LoginViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userNameBgView;
@property (weak, nonatomic) IBOutlet UIImageView *passwordBgView;
@property (weak, nonatomic) IBOutlet UITextField *userNamePwd;
@property (weak, nonatomic) IBOutlet UITextField *passwordTxd;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnTopSpace;

@property (weak, nonatomic) IBOutlet UIView *_remeberPasView;
@property (weak, nonatomic) IBOutlet UIButton *_checkBt;


@end

@implementation LoginViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (kDevice_Is_iPhoneX) {
        _topSpace.constant = 44;
        _btnTopSpace.constant = 44;
    }
    
    UITapGestureRecognizer *endDditTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditAction)];
    [self.tableView addGestureRecognizer:endDditTap];
    
    self.title = @"登录";
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    
    self.view.backgroundColor=[UIColor whiteColor];
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;

    _userNamePwd.delegate = self;
    _passwordTxd.delegate = self;
    
    _userNameBgView.image = [_userNameBgView.image resizableImageWithCapInsets:UIEdgeInsetsMake(20, 40, 20, 40)];
    _passwordBgView.image = [_passwordBgView.image resizableImageWithCapInsets:UIEdgeInsetsMake(20, 40, 20, 40)];
    
    UIView *userview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 35, _userNamePwd.height)];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 15, 15)];
    [userview addSubview:imageView];
    imageView.center = userview.center;
    imageView.image = [UIImage imageNamed:@"user"];
    _userNamePwd.leftViewMode = UITextFieldViewModeAlways;
    _userNamePwd.leftView = userview;
    _userNamePwd.layer.borderColor = [UIColor colorWithHexString:@"#d5d3d5"].CGColor;
    _userNamePwd.layer.borderWidth = 0.8;
    _userNamePwd.layer.cornerRadius = 4;
    
    UIView *pwdview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 35, _userNamePwd.height)];
    UIImageView *pwdImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 15, 15)];
    [pwdview addSubview:pwdImageView];
    pwdImageView.center = pwdview.center;
    pwdImageView.image = [UIImage imageNamed:@"pwd"];
    _passwordTxd.leftViewMode = UITextFieldViewModeAlways;
    _passwordTxd.returnKeyType = UIReturnKeyDone;
    _passwordTxd.leftView = pwdview;
    _passwordTxd.layer.borderColor = [UIColor colorWithHexString:@"#d5d3d5"].CGColor;
    _passwordTxd.layer.borderWidth = 0.8;
    _passwordTxd.layer.cornerRadius = 4;
    
    // 记住密码
    UITapGestureRecognizer *remeberTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(remeberPasActoin)];
    [__remeberPasView addGestureRecognizer:remeberTap];
    
    // 本地是否保存用户名和密码
    NSString *remeberUser = [kUserDefaults objectForKey:KRemeberUser];
    NSString *remeberPsw = [kUserDefaults objectForKey:KRemeberPassword];
    if(remeberUser != nil && remeberPsw != nil){
        _userNamePwd.text = remeberUser;
        _passwordTxd.text = remeberPsw;
        __checkBt.selected = YES;
    }
    
}
- (IBAction)remeberPsw:(id)sender {
    __checkBt.selected = !__checkBt.selected;
}

- (void)remeberPasActoin {
    __checkBt.selected = !__checkBt.selected;
}

- (void)_leftBarBtnItemClick {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self loginAction:textField];
    return YES;
}

- (IBAction)loginAction:(id)sender {
    
    if ([_userNamePwd.text isEqualToString:@""] || _userNamePwd.text.length == 0)
    {
        [self showHint:@"请输入用户名"];
        return;
    }else if ([_passwordTxd.text isEqualToString:@""] || _passwordTxd.text.length == 0)
    {
        [self showHint:@"请输入密码"];
        return;
    }
    
    [[EMClient sharedClient] loginWithUsername:@"imuser" password:@"123456" completion:^(NSString *aUsername, EMError *aError) {
        if (!aError) {
            NSLog(@"=====%d", [EMClient sharedClient].isAutoLogin);
            NSLog(@"登录成功");
            [self loginServer];
        } else {
            NSLog(@"登录失败");
            [self showHint:KRequestFailMsg];
        }
    }];
    
}

- (void)loginServer {
    NSString *userName = _userNamePwd.text;
    NSString *pwd = [_passwordTxd.text md5String];
    NSString *registrationID = [kUserDefaults objectForKey:@"registrationID"];
    NSString *deviceModel = [kUserDefaults objectForKey:KDeviceModel];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/common/login?equId=%@&equIdType=1&mobileModel=%@",Main_Url,registrationID, deviceModel];
    
    NSMutableDictionary *params = @{}.mutableCopy;
    [params setObject:userName forKey:@"userName"];
    [params setObject:pwd forKey:@"passWord"];
    
    [self showHudInView:self.view hint:@""];
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *userDic = responseObject[@"responseData"];
            [kUserDefaults setBool:YES forKey:KLoginState];
            [self dismissViewControllerAnimated:YES completion:nil];
            
            [kUserDefaults setObject:userDic[@"userName"] forKey:@"userName"];
            [kUserDefaults setObject:userDic[@"headImag"] forKey:@"headImag"];
            [kUserDefaults setObject:userDic[@"roleName"] forKey:@"roleName"];
            [kUserDefaults setObject:_userNamePwd.text forKey:KLoginUserName];
            [kUserDefaults setObject:_passwordTxd.text forKey:KLoginPasword];
            
            if(userDic[@"isRepairman"] != nil && ![userDic[@"isRepairman"] isKindOfClass:[NSNull class]] && [userDic[@"isRepairman"] isEqualToString:@"1"]){
                [kUserDefaults setBool:YES forKey:KIsRepairman];
            }
            
            // 强制重新登录完成标识
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KNewLoginFlag];
            
            // 保存companyid 和roleIdList
            if(userDic[@"companyId"] != nil && ![userDic[@"companyId"] isKindOfClass:[NSNull class]]){
                NSString *companyId = [NSString stringWithFormat:@"%@", userDic[@"companyId"]];
                [kUserDefaults setObject:companyId forKey:KAdminCompanyId];
            }
            if(userDic[@"roleIdList"] != nil && ![userDic[@"roleIdList"] isKindOfClass:[NSNull class]]){
                [kUserDefaults setObject:userDic[@"roleIdList"] forKey:KRoleIdList];
            }
            if(userDic[@"userId"] != nil && ![userDic[@"userId"] isKindOfClass:[NSNull class]]){
                [kUserDefaults setObject:userDic[@"userId"] forKey:KAdminUserId];
            }
            if(userDic[@"token"] != nil && ![userDic[@"token"] isKindOfClass:[NSNull class]]){
                [kUserDefaults setObject:userDic[@"token"] forKey:KAdminLoginToken];
            }
            
            [kNotificationCenter postNotificationName:@"loginNotification" object:nil];
            
            // 是否记住用户名和密码
            if(__checkBt.selected){
                // 记住
                [kUserDefaults setObject:_userNamePwd.text forKey:KRemeberUser];
                [kUserDefaults setObject:_passwordTxd.text forKey:KRemeberPassword];
            }else {
                // 不记住
                [kUserDefaults removeObjectForKey:KRemeberUser];
                [kUserDefaults removeObjectForKey:KRemeberPassword];
            }
        }else{
            NSString *message = responseObject[@"message"];
            if(message != nil && ![message isKindOfClass:[NSNull class]]){
                [self showHint:message];
            }
        }
    } failure:^(NSError *error) {
        [self hideHud];
        [self showHint:KRequestFailMsg];
    }];
}

#pragma mark UItextField协议
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if(textField == _userNamePwd){
        _userNameBgView.hidden = NO;
        _userNamePwd.layer.borderColor = [UIColor clearColor].CGColor;
        _passwordBgView.hidden = YES;
    }else if (textField == _passwordTxd) {
        _passwordBgView.hidden = NO;
        _passwordTxd.layer.borderColor = [UIColor clearColor].CGColor;
        _userNameBgView.hidden = YES;
    }
    return YES;
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if(textField == _userNamePwd){
        _userNameBgView.hidden = YES;
        _userNamePwd.layer.borderColor = [UIColor colorWithHexString:@"#d5d3d5"].CGColor;
    }else if (textField == _passwordTxd) {
        _passwordBgView.hidden = YES;
        _passwordTxd.layer.borderColor = [UIColor colorWithHexString:@"#d5d3d5"].CGColor;
    }
    return YES;
}

- (void)endEditAction {
    [self.tableView endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
