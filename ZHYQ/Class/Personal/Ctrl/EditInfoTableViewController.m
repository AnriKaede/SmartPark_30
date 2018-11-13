//
//  EditInfoTableViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/13.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "EditInfoTableViewController.h"

@interface EditInfoTableViewController ()
{
    __weak IBOutlet UILabel *_roleNameLabel;
    
    __weak IBOutlet UILabel *_loginNAmeLabel;
    
    __weak IBOutlet UILabel *_usernameLabel;
}
@end

@implementation EditInfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
}

- (void)_initView {
    self.title = @"个人信息";
    
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    self.tableView.tableFooterView = [UIView new];
    
    NSString *roleName = [[NSUserDefaults standardUserDefaults] objectForKey:@"roleName"];
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    NSString *loginName = [[NSUserDefaults standardUserDefaults] objectForKey:KLoginUserName];
    
    if(userName != nil){
        _roleNameLabel.text = userName; // 昵称
    }
    if(roleName != nil){
        _usernameLabel.text = roleName; // 角色
    }
    if(loginName != nil){    
        _loginNAmeLabel.text = loginName;
    }
    
}
- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
