//
//  PostmsgDetailViewController.m
//  ZHYQ
//
//  Created by coder on 2018/10/23.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "PostmsgDetailViewController.h"

@interface PostmsgDetailViewController ()
{
    __weak IBOutlet UIButton *modifyMsgBtn;
    
    __weak IBOutlet UIButton *cancleDisplayBtn;
}

@end

@implementation PostmsgDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initNav];
    
    [self initView];
}

-(void)initNav{
    self.title = @"详细内容";
    
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

-(void)initView{
    
    modifyMsgBtn.layer.cornerRadius = 4;
    modifyMsgBtn.layer.borderColor = [UIColor colorWithHexString:@"#A3A3A3"].CGColor;
    modifyMsgBtn.layer.borderWidth = 0.5;
    [modifyMsgBtn setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
    modifyMsgBtn.layer.shadowColor = [UIColor colorWithHexString:@"#CECECE"].CGColor;
    modifyMsgBtn.layer.shadowOffset = CGSizeMake(3, 3);
    modifyMsgBtn.layer.shadowOpacity = 1;
    
    cancleDisplayBtn.layer.cornerRadius = 4;
    cancleDisplayBtn.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
    cancleDisplayBtn.layer.borderWidth = 0.5;
    [cancleDisplayBtn setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
    cancleDisplayBtn.layer.shadowColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
    cancleDisplayBtn.layer.shadowOffset = CGSizeMake(3, 3);
    cancleDisplayBtn.layer.shadowOpacity = 0.31;
}

//修改
- (IBAction)modifyBtnAction:(id)sender {
    
}

//取消显示
- (IBAction)cancleDidplayAction:(id)sender {
    
}

@end
