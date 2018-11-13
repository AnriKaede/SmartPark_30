//
//  LogViewCtrl.m
//  ZHYQ
//
//  Created by 焦平 on 2017/10/22.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "LogViewCtrl.h"
#import "ForgetPdViewController.h"
#import "registerViewController.h"

#import "MD5.h"

#define Start_X 60.0f           // 第一个按钮的X坐标
#define Start_Y 440.0f           // 第一个按钮的Y坐标
#define Width_Space 50.0f        // 2个按钮之间的横间距
#define Height_Space 20.0f      // 竖间距
#define Button_Height 50.0f    // 高
#define Button_Width 50.0f      // 宽

@interface LogViewCtrl ()
{
    UIImageView *View;
    UIView *bgView;
    UITextField *pwdTexField;
    UITextField *userTexField;
    
    CGFloat topMar;
}

@property(copy,nonatomic) NSString * accountNumber;
@property(copy,nonatomic) NSString * mmmm;
@property(copy,nonatomic) NSString * user;

@end

@implementation LogViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1];
    
    //设置NavigationBar背景颜色
    View = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    //View.backgroundColor=[UIColor redColor];
    View.image = [UIImage imageNamed:@"bg4"];
    [self.view addSubview:View];
    
    self.title=@"登陆";
    UIBarButtonItem *addBtn = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(clickaddBtn:)];
    [addBtn setImage:[UIImage imageNamed:@"login_back"]];
    [addBtn setImageInsets:UIEdgeInsetsMake(0, 0, 0, 15)];
    [self.navigationItem setLeftBarButtonItem:addBtn];

//    UIBarButtonItem *right=[[UIBarButtonItem alloc]initWithTitle:@"注册" style:UIBarButtonItemStylePlain target:self action:@selector(zhuce)];
//    self.navigationItem.rightBarButtonItem=right;
    
    //为了显示背景图片自定义navgationbar上面的三个按钮
    if (kDevice_Is_iPhoneX) {
        topMar = 15;
    }else
    {
        topMar = 0;
    }
    
    [self createButtons];
    [self createTextFields];
    [self createLabel];
}

-(void)clickaddBtn:(UIButton *)button
{
    //      [kAPPDelegate appDelegateInitTabbar];
    [self.navigationController popViewControllerAnimated:YES];
    
}

-(void)createLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width-140)/2, 390, 140, 21)];
    label.text = @"第三方账号快速登录";
    label.textColor = [UIColor grayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:14];
//    [self.view addSubview:label];
    
}

-(void)createTextFields
{
    CGRect frame = [UIScreen mainScreen].bounds;
    bgView = [[UIView alloc] initWithFrame:CGRectMake(10, 20, frame.size.width-20, 100)];
    bgView.layer.cornerRadius = 3.0;
    bgView.alpha = 0.7;
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    
    userTexField = [self createTextFielfFrame:CGRectMake(60, 10, 271, 30) font:[UIFont systemFontOfSize:14] placeholder:@"请输入您手机号码"];
    userTexField.text = @"admin";
    userTexField.keyboardType = UIKeyboardTypeDefault;
    userTexField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    pwdTexField = [self createTextFielfFrame:CGRectMake(60, 60, 271, 30) font:[UIFont systemFontOfSize:14]  placeholder:@"密码" ];
    pwdTexField.clearButtonMode = UITextFieldViewModeWhileEditing;
    pwdTexField.text = @"96e79218965eb72c92a549dd5a330112";
    //密文样式
    pwdTexField.secureTextEntry = YES;
    
    UIImageView *userImageView = [self createImageViewFrame:CGRectMake(20, 10, 25, 25) imageName:@"ic_landing_nickname" color:nil];
    UIImageView *pwdImageView = [self createImageViewFrame:CGRectMake(20, 60, 25, 25) imageName:@"mm_normal" color:nil];
    UIImageView *line1 = [self createImageViewFrame:CGRectMake(20, 50, bgView.frame.size.width-40, 1) imageName:nil color:[UIColor colorWithRed:180/255.0f green:180/255.0f blue:180/255.0f alpha:.3]];
    
    [bgView addSubview:userTexField];
    [bgView addSubview:pwdTexField];
    
    [bgView addSubview:userImageView];
    [bgView addSubview:pwdImageView];
    [bgView addSubview:line1];
}

-(void)touchesEnded:(nonnull NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    [userTexField resignFirstResponder];
    [pwdTexField resignFirstResponder];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [userTexField resignFirstResponder];
    [pwdTexField resignFirstResponder];
}

-(void)createButtons
{
    //登录
    UIButton *landBtn = [self createButtonFrame:CGRectMake(10, 145+topMar, self.view.frame.size.width-20, 37) backImageName:nil title:@"登录" titleColor:[UIColor whiteColor]  font:[UIFont systemFontOfSize:19] target:self action:@selector(landClick)];
    landBtn.backgroundColor = [UIColor colorWithHexString:@"1B82D1"];
    landBtn.layer.cornerRadius = 5.0f;
    
    //注册新用户
    UIButton *newUserBtn = [self createButtonFrame:CGRectMake(5, 185+topMar, 70, 30) backImageName:nil title:@"快速注册" titleColor:[UIColor grayColor] font:[UIFont systemFontOfSize:13] target:self action:@selector(registration:)];
    //忘记密码
    UIButton *forgotPwdBtn = [self createButtonFrame:CGRectMake(self.view.frame.size.width-75, 185+topMar, 60, 30) backImageName:nil title:@"找回密码" titleColor:[UIColor grayColor] font:[UIFont systemFontOfSize:13] target:self action:@selector(fogetPwd:)];

    [self.view addSubview:landBtn];
//    [self.view addSubview:newUserBtn];
//    [self.view addSubview:forgotPwdBtn];
}

-(UITextField *)createTextFielfFrame:(CGRect)frame font:(UIFont *)font placeholder:(NSString *)placeholder
{
    UITextField *textField = [[UITextField alloc]initWithFrame:frame];
    
    textField.font = font;
    
    textField.textColor = [UIColor grayColor];
    
    textField.borderStyle = UITextBorderStyleNone;
    
    textField.placeholder = placeholder;
    
    return textField;
}

-(UIImageView *)createImageViewFrame:(CGRect)frame imageName:(NSString *)imageName color:(UIColor *)color
{
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:frame];
    
    if (imageName)
    {
        imageView.image = [UIImage imageNamed:imageName];
    }
    if (color)
    {
        imageView.backgroundColor = color;
    }
    
    return imageView;
}

-(UIButton *)createButtonFrame:(CGRect)frame backImageName:(NSString *)imageName title:(NSString *)title titleColor:(UIColor *)color font:(UIFont *)font target:(id)target action:(SEL)action
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    if (imageName)
    {
        [btn setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    
    if (font)
    {
        btn.titleLabel.font=font;
    }
    
    if (title)
    {
        [btn setTitle:title forState:UIControlStateNormal];
    }
    if (color)
    {
        [btn setTitleColor:color forState:UIControlStateNormal];
    }
    if (target&&action)
    {
        [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    }
    return btn;
}

#pragma  mark 登录
-(void)landClick
{
    
    if ([userTexField.text isEqualToString:@""] || userTexField.text.length == 0)
    {
        [self showHint:@"请输入用户名"];
        return;
    }
    /*
    else if (![Utils valiMobile:userTexField.text])
    {
        [self showHint:@"您输入的手机号码格式不正确"];
        return;
    }*/
    else if ([pwdTexField.text isEqualToString:@""] || pwdTexField.text.length == 0)
    {
        
        [self showHint:@"请输入密码"];
        return;
    }
    /*
    else if (pwdTexField.text.length <6)
    {
        [self showHint:@"密码长度至少六位"];
        return;
    }
    */
//    NSString *md5PasW = [MD5 md5:pwdTexField.text];
    NSString *pwd = pwdTexField.text;
    NSString *userName = userTexField.text;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/common/login",Main_Url];
    
    NSMutableDictionary *params = @{}.mutableCopy;
    [params setObject:userName forKey:@"userName"];
    [params setObject:pwd forKey:@"passWord"];
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        DLog(@"%@",responseObject);
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            NSDictionary *userDic = responseObject[@"responseData"];
            [kUserDefaults setBool:YES forKey:KLoginState];
            [kUserDefaults setObject:userDic[@"loginName"] forKey:KLoginUserName];
            [self.navigationController popViewControllerAnimated:YES];
        }
    } failure:^(NSError *error) {
        DLog(@"%@",error);
    }];
}

//注册
-(void)zhuce
{
    [self.navigationController pushViewController:[[registerViewController alloc]init] animated:YES];
}

-(void)registration:(UIButton *)button
{
    [self.navigationController pushViewController:[[registerViewController alloc]init] animated:YES];
}

-(void)fogetPwd:(UIButton *)button
{
    [self.navigationController pushViewController:[[ForgetPdViewController alloc]init] animated:YES];
}

#pragma mark - 工具
//手机号格式化
-(NSString*)getHiddenStringWithPhoneNumber:(NSString*)number middle:(NSInteger)countHiiden{
    // if (number.length>6) {
    
    if (number.length<countHiiden) {
        return number;
    }
    NSInteger count = countHiiden;
    NSInteger leftCount = number.length/2-count/2;
    NSString *xings = @"";
    for (int i=0; i<count; i++) {
        xings = [NSString stringWithFormat:@"%@%@",xings,@"*"];
    }
    
    NSString *str = [number stringByReplacingCharactersInRange:NSMakeRange(leftCount, count) withString:xings];
    // chuLi=[chuLi stringByReplacingCharactersInRange:NSMakeRange(number.length-count, count-leftCount) withString:xings];
    
    return str;
}

//手机号格式化后还原
-(NSString*)getHiddenStringWithPhoneNumber1:(NSString*)number middle:(NSInteger)countHiiden{
    // if (number.length>6) {
    if (number.length<countHiiden) {
        return number;
    }
    NSString *xings = @"";
    for (int i=0; i<1; i++) {
        //xings=[NSString stringWithFormat:@"%@",[CheckTools getUser]];
    }
    
    NSString *str = [number stringByReplacingCharactersInRange:NSMakeRange(0, 0) withString:@""];
    // chuLi=[chuLi stringByReplacingCharactersInRange:NSMakeRange(number.length-count, count-leftCount) withString:xings];
    
    return str;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
