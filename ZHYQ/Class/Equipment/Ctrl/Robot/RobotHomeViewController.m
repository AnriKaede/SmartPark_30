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
#import "MQTTTool.h"

#import "RobotInfoModel.h"

@interface RobotHomeViewController ()<OperateDelegate, MQTTMessageDelegate>
{
    __weak IBOutlet UILabel *_stateLabel;
    __weak IBOutlet UILabel *_powerValueLabel;
    
    __weak IBOutlet UIImageView *_robotImgView;
    __weak IBOutlet UIButton *_moreBt;
    
    RobotMenuView *_robotMenuView;
    
    RobotInfoModel *_infoModel;
    
    UIButton *_showDownBt;
    UILabel *_showDownLabel;
}
@end

@implementation RobotHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
    
    [self setupRobot];
}

- (void)_initView {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(8, 30, 30, 30);
    [button setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(popAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    _robotMenuView = [[UINib nibWithNibName:@"RobotMenuView" bundle:nil] instantiateWithOwner:self options:nil].lastObject;
    _robotMenuView.frame = CGRectMake(0, KScreenHeight, KScreenWidth, 133);
    _robotMenuView.operateDelegate = self;
    [self.view addSubview:_robotMenuView];
    
    _showDownBt = [UIButton buttonWithType:UIButtonTypeCustom];
    _showDownBt.frame = CGRectMake((KScreenWidth - 37)/2, KScreenHeight - 93, 37, 37);
    [_showDownBt setImage:[UIImage imageNamed:@"robot_showdown"] forState:UIControlStateNormal];
    [_showDownBt addTarget:self action:@selector(showDownRobot) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_showDownBt];
    
    _showDownLabel = [[UILabel alloc] initWithFrame:CGRectMake((KScreenWidth - 150)/2, _showDownBt.bottom + 3, 150, 20)];
    _showDownLabel.text = @"关闭机器人";
    _showDownLabel.textColor = [UIColor whiteColor];
    _showDownLabel.font = [UIFont systemFontOfSize:12];
    _showDownLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_showDownLabel];
}
- (void)popAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupRobot {
    if([MQTTTool shareInstance].mySession.status != MQTTSessionStatusConnected){
        [[MQTTTool shareInstance] bindUser:^(BOOL isSuccess) {
            if(isSuccess){
                [self subscribeTopics];
            }
        }];
    }else {
        [self subscribeTopics];
    }
    // 单例协议只生效最后设置
    [MQTTTool shareInstance].messageDelegate = self;
}
- (void)subscribeTopics {
    // 订阅电量主题
    [[MQTTTool shareInstance] subscribeTopic:@"RobotMsg" withSubscribe:^(BOOL isSuccess) {
        NSLog(@"电量主题订阅 %d", isSuccess);
        [self achievePower];
    }];
    // 订阅系统信息主题
    [[MQTTTool shareInstance] subscribeTopic:@"sysMsg" withSubscribe:^(BOOL isSuccess) {
        NSLog(@"系统信息主题订阅 %d", isSuccess);
        [self achieveRobotInfo];
    }];
}
- (void)achievePower {
    [[MQTTTool shareInstance] sendDataToTopic:@"power" string:@"11"];
}
- (void)achieveRobotInfo {
    [[MQTTTool shareInstance] sendDataToTopic:@"systemMessage" string:@"11"];
}

#pragma mark MQTT协议接收数据
- (void)messageData:(NSData *)data onTopic:(NSString *)topic {
    if([topic isEqualToString:@"RobotMsg"]){
        NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        _powerValueLabel.text = [NSString stringWithFormat:@"%@%%", jsonData];
    }else if([topic isEqualToString:@"sysMsg"]){
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        _infoModel = [[RobotInfoModel alloc] initWithDataDic:jsonData];
        NSLog(@"%@", jsonData);
    }
}

- (void)livePlay {
    RobotLiveViewController *liveVC = [[UIStoryboard storyboardWithName:@"Equipment" bundle:nil] instantiateViewControllerWithIdentifier:@"RobotLiveViewController"];
    [self presentViewController:liveVC animated:YES completion:nil];
}

-(void)showDownRobot {
    UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:@"确认是否关闭机器人" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *removeAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[MQTTTool shareInstance] sendDataToTopic:@"powerOff" string:@"111"];
    }];
    [alertCon addAction:cancelAction];
    [alertCon addAction:removeAction];
    if (alertCon.popoverPresentationController != nil) {
        alertCon.popoverPresentationController.sourceView = _showDownBt;
        alertCon.popoverPresentationController.sourceRect = _showDownBt.bounds;
    }
    [self presentViewController:alertCon animated:YES completion:^{
    }];
}
- (void)closeMenu {
    _moreBt.hidden = NO;
    _showDownBt.hidden = NO;
    _showDownLabel.hidden = NO;
}
- (void)robotMove:(RobotMove)robotMove {
    switch (robotMove) {
        case RobotMoveTop:
        {
            [[MQTTTool shareInstance] sendDataToTopic:@"move" string:@"front"];
        }
            break;
        case RobotMoveLeft:
        {
            [[MQTTTool shareInstance] sendDataToTopic:@"move" string:@"left"];
        }
            break;
        case RobotMoveDown:
        {
            [[MQTTTool shareInstance] sendDataToTopic:@"move" string:@"back"];
        }
            break;
        case RobotMoveRight:
        {
            [[MQTTTool shareInstance] sendDataToTopic:@"move" string:@"right"];
        }
            break;
            
        default:
            break;
    }
}
- (void)changeColor {
    [[MQTTTool shareInstance] sendDataToTopic:@"eye" string:@"111"];
}
- (void)shakeHeader {
    [[MQTTTool shareInstance] sendDataToTopic:@"bindAction" string:@"111"];
}

///
- (IBAction)moreAction:(UIButton *)sender {
    _moreBt.hidden = YES;
    _showDownBt.hidden = YES;
    _showDownLabel.hidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
        _robotMenuView.frame = CGRectMake(0, KScreenHeight-188, KScreenWidth, 188);
    }];
}

- (IBAction)infoAction:(id)sender {
    self.navigationController.navigationBar.hidden = YES;
    RobotInfoViewController *infoVC = [[RobotInfoViewController alloc] init];
    infoVC.infoModel = _infoModel;
    [self.navigationController pushViewController:infoVC animated:YES];
}

@end
