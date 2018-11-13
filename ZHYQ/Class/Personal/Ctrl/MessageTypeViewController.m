//
//  MessageTypeViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/5/29.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "MessageTypeViewController.h"
#import "UITabBar+CustomBadge.h"
#import "MessageCenViewController.h"

#import "MessageTypeModel.h"

@interface MessageTypeViewController ()
{
    __weak IBOutlet UILabel *_loginTimeLabel;
    __weak IBOutlet UILabel *_loginNewMsgLabel;
    __weak IBOutlet UILabel *_loginUnReadNumMsgLabel;
    
    __weak IBOutlet UILabel *_warnTimeLabel;
    __weak IBOutlet UILabel *_warnNewMsgLabel;
    __weak IBOutlet UILabel *_warnUnReadNumMsgLabel;
    
    __weak IBOutlet UILabel *_billTimeLabel;
    __weak IBOutlet UILabel *_billNewMsgLabel;
    __weak IBOutlet UILabel *_biullUnReadNumMsgLabel;
 
    NSDictionary *_msgResDic;
}
@end

@implementation MessageTypeViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([kUserDefaults boolForKey:KLoginState]) {
        [self _loadData];
        [self _loadMsgData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
    
    [kNotificationCenter addObserver:self selector:@selector(_loadData) name:@"loginNotification" object:nil];
    
    /*
    if ([kUserDefaults boolForKey:KLoginState]) {
        [self _loadData];
        [self _loadMsgData];
    }
     */
    
    // 接受网络变化通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeNetworkSel) name:@"ResumeNetworkNotification" object:nil];
    
}

- (void)_initView {
    self.tableView.tableFooterView = [UIView new];
    
    _loginUnReadNumMsgLabel.layer.cornerRadius = _loginUnReadNumMsgLabel.height/2;
    _loginUnReadNumMsgLabel.clipsToBounds = YES;
    _warnUnReadNumMsgLabel.layer.cornerRadius = _warnUnReadNumMsgLabel.height/2;
    _warnUnReadNumMsgLabel.clipsToBounds = YES;
    _biullUnReadNumMsgLabel.layer.cornerRadius = _biullUnReadNumMsgLabel.height/2;
    _biullUnReadNumMsgLabel.clipsToBounds = YES;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self _loadData];
        [self _loadMsgData];
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"一键已读" style:UIBarButtonItemStylePlain target:self action:@selector(rightAction)];
}

#pragma mark 恢复网络通知
- (void)resumeNetworkSel {
    if ([kUserDefaults boolForKey:KLoginState]) {
        [self _loadData];
        [self _loadMsgData];
    }
}

- (void)_loadData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/public/getMessageStatus", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:@"admin" forKey:@"appType"];
    NSString *loginName = [[NSUserDefaults standardUserDefaults] objectForKey:KLoginUserName];
    if(loginName != nil){
        [paramDic setObject:loginName forKey:@"loginName"];
    }
    
    NSDictionary *param = @{@"param":[Utils convertToJsonData:paramDic]};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        [self.tableView.mj_header endRefreshing];
        if(responseObject[@"code"] != nil && ![responseObject[@"code"] isKindOfClass:[NSNull class]] && [responseObject[@"code"] isEqualToString:@"1"]){
            
            NSDictionary *responseData = responseObject[@"responseData"];
            [self updateViewWithDic:responseData];
            
            _msgResDic = responseData;
            
        }else if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
            [self showHint:responseObject[@"message"]];
        }
        
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
    }];
}

#pragma mark 一键已读
- (void)rightAction {
    UIAlertControllerStyle alertControllerStyle;
    if(KScreenWidth > 440){
        // ipad
        alertControllerStyle = UIAlertControllerStyleAlert;
    }else {
        alertControllerStyle = UIAlertControllerStyleActionSheet;
    }
    
    UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定将未读消息全部标记为已读？" preferredStyle:alertControllerStyle];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *open = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self allReadAction];
    }];
    [alertCon addAction:cancel];
    [alertCon addAction:open];
    
    [self presentViewController:alertCon animated:YES completion:nil];
}
- (void)allReadAction {
    NSString *urlStr = [NSString stringWithFormat:@"%@/public/readAllMessage", Main_Url];
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:@"admin" forKey:@"appType"];
    NSString *loginName = [[NSUserDefaults standardUserDefaults] objectForKey:KLoginUserName];
    if(loginName != nil){
        [paramDic setObject:loginName forKey:@"loginName"];
    }
    [paramDic setObject:@"" forKey:@"messageType"];
    
    NSDictionary *param = @{@"param":[Utils convertToJsonData:paramDic]};
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        [self.tableView.mj_header endRefreshing];
        if(responseObject[@"code"] != nil && ![responseObject[@"code"] isKindOfClass:[NSNull class]] && [responseObject[@"code"] isEqualToString:@"1"]){
            
            // 已读完成刷新未读消息
            [self _loadData];
            [self _loadMsgData];
            
        }
        if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
            [self showHint:responseObject[@"message"]];
        }
        
    } failure:^(NSError *error) {
        [self.tableView.mj_header endRefreshing];
    }];
}

#pragma mark 更新视图
- (void)updateViewWithDic:(NSDictionary *)dic {
    MessageTypeModel *loginMsgModel = [[MessageTypeModel alloc] initWithDataDic:dic[@"login"]];
    MessageTypeModel *warnMsgModel = [[MessageTypeModel alloc] initWithDataDic:dic[@"alarm"]];
    MessageTypeModel *billMsgModel = [[MessageTypeModel alloc] initWithDataDic:dic[@"order"]];
    
    if(loginMsgModel.messageModel.PUSH_TIMESTR != nil && ![loginMsgModel.messageModel.PUSH_TIMESTR isKindOfClass:[NSNull class]]){
        _loginTimeLabel.hidden = NO;
        _loginTimeLabel.text = [NSString stringWithFormat:@"%@", loginMsgModel.messageModel.PUSH_TIMESTR];
    }else {
        _loginTimeLabel.hidden = YES;
    }
    if(loginMsgModel.messageModel.PUSH_CONTENT != nil && ![loginMsgModel.messageModel.PUSH_CONTENT isKindOfClass:[NSNull class]]){
        _loginNewMsgLabel.text = [NSString stringWithFormat:@"%@", loginMsgModel.messageModel.PUSH_CONTENT];
    }else {
        _loginNewMsgLabel.text = @"暂无消息";
    }
    if(loginMsgModel.UNREAD_SUM != nil && ![loginMsgModel.UNREAD_SUM isKindOfClass:[NSNull class]] && loginMsgModel.UNREAD_SUM.integerValue > 0){
        _loginUnReadNumMsgLabel.hidden = NO;
        if(loginMsgModel.UNREAD_SUM.integerValue > 99){
            _loginUnReadNumMsgLabel.text = @"99+";
        }else {
            _loginUnReadNumMsgLabel.text = [NSString stringWithFormat:@"%@", loginMsgModel.UNREAD_SUM];
        }
    }else {
        _loginUnReadNumMsgLabel.text = @"0";
        _loginUnReadNumMsgLabel.hidden = YES;
    }
    
    if(warnMsgModel.messageModel.PUSH_TIMESTR != nil && ![warnMsgModel.messageModel.PUSH_TIMESTR isKindOfClass:[NSNull class]]){
        _warnTimeLabel.hidden = NO;
        _warnTimeLabel.text = [NSString stringWithFormat:@"%@", warnMsgModel.messageModel.PUSH_TIMESTR];
    }else {
        _warnTimeLabel.hidden = YES;
    }
    if(warnMsgModel.messageModel.PUSH_CONTENT != nil && ![warnMsgModel.messageModel.PUSH_CONTENT isKindOfClass:[NSNull class]]){
        _warnNewMsgLabel.text = [NSString stringWithFormat:@"%@", warnMsgModel.messageModel.PUSH_CONTENT];
    }else {
        _warnNewMsgLabel.text = @"暂无消息";
    }
    if(warnMsgModel.UNREAD_SUM != nil && ![warnMsgModel.UNREAD_SUM isKindOfClass:[NSNull class]] && warnMsgModel.UNREAD_SUM.integerValue > 0){
        _warnUnReadNumMsgLabel.hidden = NO;
        if(warnMsgModel.UNREAD_SUM.integerValue > 99){
            _warnUnReadNumMsgLabel.text = @"99+";
        }else {
            _warnUnReadNumMsgLabel.text = [NSString stringWithFormat:@"%@", warnMsgModel.UNREAD_SUM];
        }
    }else {
        _warnUnReadNumMsgLabel.text = @"0";
        _warnUnReadNumMsgLabel.hidden = YES;
    }
    
    if(billMsgModel.messageModel.PUSH_TIMESTR != nil && ![billMsgModel.messageModel.PUSH_TIMESTR isKindOfClass:[NSNull class]]){
        _billTimeLabel.hidden = NO;
        _billTimeLabel.text = [NSString stringWithFormat:@"%@", billMsgModel.messageModel.PUSH_TIMESTR];
    }else {
        _billTimeLabel.hidden = YES;
    }
    if(billMsgModel.messageModel.PUSH_CONTENT != nil && ![billMsgModel.messageModel.PUSH_CONTENT isKindOfClass:[NSNull class]]){
        _billNewMsgLabel.text = [NSString stringWithFormat:@"%@", billMsgModel.messageModel.PUSH_CONTENT];
    }else {
        _billNewMsgLabel.text = @"暂无消息";
    }
    if(billMsgModel.UNREAD_SUM != nil && ![billMsgModel.UNREAD_SUM isKindOfClass:[NSNull class]] && billMsgModel.UNREAD_SUM.integerValue > 0){
        _biullUnReadNumMsgLabel.hidden = NO;
        if(billMsgModel.UNREAD_SUM.integerValue > 99){
            _biullUnReadNumMsgLabel.text = @"99+";
        }else {
            _biullUnReadNumMsgLabel.text = [NSString stringWithFormat:@"%@", billMsgModel.UNREAD_SUM];
        }
    }else {
        _biullUnReadNumMsgLabel.text = @"0";
        _biullUnReadNumMsgLabel.hidden = YES;
    }
}

#pragma mark 加载未读消息
- (void)_loadMsgData {
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:KLoginUserName];
    NSString *urlStr = [NSString stringWithFormat:@"%@/public/getUnreadMessage?appType=%@&loginName=%@",Main_Url, @"admin", username];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        NSDictionary *data = responseObject;
        if ([data[@"code"] isEqualToString:@"1"]) {
            NSNumber *msgNum = responseObject[@"responseData"];
            if(msgNum != nil && ![msgNum isKindOfClass:[NSNull class]] && msgNum.integerValue > 0){
                [self.tabBarController.tabBar setBadgeStyle:kCustomBadgeStyleRedDot value:0 atIndex:2];
            }else {
                [self.tabBarController.tabBar setBadgeStyle:kCustomBadgeStyleNone value:0 atIndex:2];
            }
        }
        
    } failure:^(NSError *error) {
    }];
    
}

-(void)dealloc
{
    [kNotificationCenter removeObserver:self name:@"loginNotification" object:nil];
    
    [kNotificationCenter removeObserver:self name:@"NotNetworkNotification" object:nil];
    [kNotificationCenter removeObserver:self name:@"ResumeNetworkNotification" object:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController pushViewController:[self messageVC:(int)indexPath.row] animated:YES];
}
- (MessageCenViewController *)messageVC:(int)selIndex {
    MessageCenViewController *msgVC = [[MessageCenViewController alloc] init];
    msgVC.selectIndex = selIndex;
    
    MessageTypeModel *loginMsgModel = [[MessageTypeModel alloc] initWithDataDic:_msgResDic[@"login"]];
    MessageTypeModel *warnMsgModel = [[MessageTypeModel alloc] initWithDataDic:_msgResDic[@"alarm"]];
    MessageTypeModel *billMsgModel = [[MessageTypeModel alloc] initWithDataDic:_msgResDic[@"order"]];
    
    if(loginMsgModel != nil && loginMsgModel.UNREAD_SUM != nil){
        msgVC.loginUnreadNum = loginMsgModel.UNREAD_SUM.intValue;
    }else {
        msgVC.loginUnreadNum = 0;
    }
    if(warnMsgModel != nil && warnMsgModel.UNREAD_SUM != nil){
        msgVC.warnUnreadNum = warnMsgModel.UNREAD_SUM.intValue;
    }else {
        msgVC.warnUnreadNum = 0;
    }
    if(billMsgModel != nil && billMsgModel.UNREAD_SUM != nil){
        msgVC.billUnreadNum = billMsgModel.UNREAD_SUM.intValue;
    }else {
        msgVC.billUnreadNum = 0;
    }
    return msgVC;
}

@end
