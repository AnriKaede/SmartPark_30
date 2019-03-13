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
    
    BOOL _isPowerRevice;
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
    
    __block int timeout = 3;
    dispatch_queue_t global = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, global);
    // 设置触发的间隔时间
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    //1.0 * NSEC_PER_SEC  代表设置定时器触发的时间间隔为1s
    //0 * NSEC_PER_SEC    代表时间允许的误差是 0s
    __weak typeof(self)weakSelf = self;
    //设置定时器的触发事件
    dispatch_source_set_event_handler(timer, ^{
        //1. 每调用一次 时间-1s
        timeout --;
        //2.对timeout进行判断
        if (timeout <= 0) {
            //停止倒计时
            //关闭定时器
            dispatch_source_cancel(timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (_isPowerRevice) {
                    _stateLabel.text = [NSString stringWithFormat:@"正常"];
                }else{
                    _stateLabel.textColor = [UIColor colorWithHexString:@"#e2e2e2"];
                    _stateLabel.text = [NSString stringWithFormat:@"关闭"];
                }
            });
        }else {
            //处于正在倒计时，在主线程中刷新
            dispatch_async(dispatch_get_main_queue(), ^{
                if (_isPowerRevice) {
                    dispatch_source_cancel(timer);
                }else{
                    _stateLabel.text = [NSString stringWithFormat:@"正常"];
                }
            });
        }
    });

    dispatch_resume(timer);
}

- (void)achieveRobotInfo {
    [[MQTTTool shareInstance] sendDataToTopic:@"systemMessage" string:@"11"];
}

#pragma mark MQTT协议接收数据
- (void)messageData:(NSData *)data onTopic:(NSString *)topic {
    if([topic isEqualToString:@"RobotMsg"]){
        _isPowerRevice = YES;
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
- (void)shakeHand {
    [[MQTTTool shareInstance] sendDataToTopic:@"hand" string:@"111"];
}

-(void)shakeHead:(RobotShakeHead)robotShakeHeader
{
    switch (robotShakeHeader) {
            case RobotShakeHeadLeft:
                {
                    
                }
                break;
            case RobotShakeHeadRight:
                {
                    
                }
                break;
            case RobotShakeHeadCenter:
                {
                    [[MQTTTool shareInstance] sendDataToTopic:@"head" string:@"2"];
                }
                break;
            default:
                break;
    }
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

- (IBAction)speakAction:(id)sender {
    [[MQTTTool shareInstance] sendDataToTopic:@"speak" string:@"测试说话"];
}

- (IBAction)headerLeftAction:(id)sender {
    [[MQTTTool shareInstance] sendDataToTopic:@"head" string:@"0"];
}

- (IBAction)headerRightAction:(id)sender {
    [[MQTTTool shareInstance] sendDataToTopic:@"head" string:@"1"];
}

- (IBAction)eyesChangeColorAction:(id)sender {
    [[MQTTTool shareInstance] sendDataToTopic:@"eye" string:@"111"];
}

- (IBAction)rightHandsAction:(id)sender {
    [[MQTTTool shareInstance] sendDataToTopic:@"hand" string:@"111"];
}

- (IBAction)leftHandsAction:(id)sender {
    [[MQTTTool shareInstance] sendDataToTopic:@"hand" string:@"111"];
}

@end
