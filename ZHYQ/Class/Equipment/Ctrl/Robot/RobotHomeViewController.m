//
//  RobotHomeViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/2/27.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "RobotHomeViewController.h"
#import "RobotInfoViewController.h"
#import "RobotMenuView.h"
#import "RobotLiveViewController.h"
#import "YQSwitch.h"

@interface RobotHomeViewController ()<OperateDelegate, switchTapDelegate>
{
    __weak IBOutlet UILabel *_stateLabel;
    __weak IBOutlet UILabel *_powerValueLabel;
    
    __weak IBOutlet UIImageView *_robotImgView;
    __weak IBOutlet UIButton *_moreBt;
    
    RobotMenuView *_robotMenuView;
    
    YQSwitch *yqSwtch;
}
@end

@implementation RobotHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
}

- (void)_initView {
    _robotMenuView = [[UINib nibWithNibName:@"RobotMenuView" bundle:nil] instantiateWithOwner:self options:nil].lastObject;
    _robotMenuView.frame = CGRectMake(0, KScreenHeight, KScreenWidth, 133);
    _robotMenuView.operateDelegate = self;
    [self.view addSubview:_robotMenuView];
    
    yqSwtch = [[YQSwitch alloc] initWithFrame:CGRectMake(KScreenWidth - 150, KScreenHeight - 78, 70, 20)];
    yqSwtch.tag = 2000;
    yqSwtch.onText = @"ON";
    yqSwtch.offText = @"OFF";
    yqSwtch.on = NO;
    yqSwtch.backgroundColor = [UIColor clearColor];
//    yqSwtch.onTintColor = [UIColor colorWithHexString:@"6BDB6A"];
//    yqSwtch.tintColor = [UIColor colorWithHexString:@"FF4359"];
    yqSwtch.onTintColor = [UIColor colorWithHexString:@"7f91bc"];
    yqSwtch.tintColor = [UIColor colorWithHexString:@"7f91bc"];
    //    yqSwtch.tintColor = [UIColor colorWithHexString:@"ffffff"];
    yqSwtch.switchDelegate = self;
    [self.view addSubview:yqSwtch];
}

- (void)livePlay {
    RobotLiveViewController *liveVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"RobotLiveViewController"];
    [self presentViewController:liveVC animated:YES completion:nil];
}

-(void)switchTap:(BOOL)on {
    
}

- (IBAction)infoAction:(id)sender {
    self.navigationController.navigationBar.hidden = YES;
//    RobotInfoViewController *infoVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"RobotInfoViewController"];
    RobotInfoViewController *infoVC = [[RobotInfoViewController alloc] init];
    [self.navigationController pushViewController:infoVC animated:YES];
}
- (void)closeMenu {
    _moreBt.hidden = NO;
    yqSwtch.hidden = NO;
}

- (IBAction)moreAction:(UIButton *)sender {
    _moreBt.hidden = YES;
    yqSwtch.hidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
        _robotMenuView.frame = CGRectMake(0, KScreenHeight-188, KScreenWidth, 188);
    }];
}

@end
