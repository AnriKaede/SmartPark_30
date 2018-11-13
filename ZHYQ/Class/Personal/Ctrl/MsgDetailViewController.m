//
//  MsgDetailViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/3/7.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "MsgDetailViewController.h"
#import "CalculateHeight.h"

#import "WorkDetailViewController.h"

@interface MsgDetailViewController ()
{
    __weak IBOutlet UILabel *_titleLabel;
    __weak IBOutlet UILabel *_msgLabel;
    __weak IBOutlet UILabel *_timeLabel;
    
    
    __weak IBOutlet UIView *_bgView;
    __weak IBOutlet NSLayoutConstraint *_bgViewHeight;
}
@end

@implementation MsgDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
}

- (void)_initView {
    self.title = @"消息详情";
    self.view.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    _titleLabel.text = _messageModel.PUSH_TITLE;
    
    _msgLabel.text = _messageModel.PUSH_CONTENT;
    
    // 根据内容自适应高度
    _bgViewHeight.constant += ([CalculateHeight heightForString:_messageModel.PUSH_CONTENT fontSize:17 andWidth:KScreenWidth - 34] - 15);
    
    _timeLabel.text = _messageModel.PUSH_TIMESTR;
    
    UITapGestureRecognizer *linkTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(linkAction)];
    [_bgView addGestureRecognizer:linkTap];
}
- (void)linkAction {
    if(_messageModel.MESSAGE_TYPE != nil && ![_messageModel.MESSAGE_TYPE isKindOfClass:[NSNull class]] && [_messageModel.MESSAGE_TYPE isEqualToString:@"02"]){
        // 工单消息
        
        WorkDetailViewController *detailVC = [[UIStoryboard storyboardWithName:@"Personal" bundle:nil] instantiateViewControllerWithIdentifier:@"WorkDetailViewController"];
        detailVC.orderId = _messageModel.MESSAGE_PUSH_INDEX;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
