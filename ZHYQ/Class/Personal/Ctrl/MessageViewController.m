//
//  MessageViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/13.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "MessageViewController.h"
#import "MessageCell.h"
#import "MessageModel.h"
#import <CYLTableViewPlaceHolder.h>
#import "noDataView.h"
#import "MsgDetailViewController.h"

#import "CalculateHeight.h"

#import "UITabBar+CustomBadge.h"

@interface MessageViewController ()<UITableViewDelegate, UITableViewDataSource, CYLTableViewPlaceHolderDelegate>
{
    UITableView *_msgTableView;
    
    NSMutableArray *_msgData;
    int _page;
    int _length;
    
    NoDataView *noDataView;
    
    NSMutableDictionary *_filterDic;
    
    NSString *_beginTime;
    NSString *_endTime;
}
@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _msgData = @[].mutableCopy;
    _page = 1;
    _length = 15;
    
    [self _initView];
    
    [_msgTableView.mj_header beginRefreshing];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetData) name:@"MessageResSet" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filterDataDic:) name:@"MessageFilter" object:nil];
}

- (void)_initView {
    
    _msgTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64 - 60) style:UITableViewStylePlain];
    _msgTableView.backgroundColor = [UIColor whiteColor];
    _msgTableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    _msgTableView.dataSource = self;
    _msgTableView.delegate = self;
    _msgTableView.tableFooterView = [UIView new];
    [self.view addSubview:_msgTableView];

    // ios 11tableView闪动
    _msgTableView.estimatedRowHeight = 0;
    _msgTableView.estimatedSectionHeaderHeight = 0;
    _msgTableView.estimatedSectionFooterHeight = 0;
    
    [_msgTableView registerNib:[UINib nibWithNibName:@"MessageCell" bundle:nil] forCellReuseIdentifier:@"MessageCell"];
    
    _msgTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 1;
        [self _loadData];
    }];
    
    _msgTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _page ++;
        [self _loadData];
    }];
//    _msgTableView.mj_footer.automaticallyHidden = NO;
    _msgTableView.mj_footer.hidden = YES;
    
    // 无数据视图
    noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64-49)];
    noDataView.imgView.image = [UIImage imageNamed:@"no_message"];
    noDataView.label.text = @"暂时没有消息~";
    noDataView.label.textColor = [UIColor colorWithHexString:@"#1B82D1"];
    
}

// 重置数据
- (void)resetData {
    [_filterDic removeAllObjects];
    [_msgTableView.mj_header beginRefreshing];
}

// 筛选通知
- (void)filterDataDic:(NSNotification *)notifacation {
    _page = 1;
    [_msgData removeAllObjects];
    
    [_msgTableView reloadData];
    
    _filterDic = notifacation.userInfo.mutableCopy;
    [_msgTableView.mj_header beginRefreshing];
}

#pragma mark 无网络通知
- (void)noNetworkSel {
    noDataView.hidden = NO;
    noDataView.imgView.image = [UIImage imageNamed:@"customvoice_networkerror"];
    noDataView.label.text = @"对不起,网络连接失败";
}

- (void)_loadData {
    
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:@"admin" forKey:@"appType"];
    NSString *loginName = [kUserDefaults objectForKey:KLoginUserName];
    if(loginName != nil){
        [paramDic setObject:loginName forKey:@"loginName"];
    }
    
    NSString *MESSAGE_TYPE = @"";
    switch (_messageType) {
        case LoginMessage:
            MESSAGE_TYPE = @"01";
            break;
        case WranMessage:
            MESSAGE_TYPE = @"03";
            break;
        case BillMessage:
            MESSAGE_TYPE = @"02";
            break;
    }
    [paramDic setObject:MESSAGE_TYPE forKey:@"messageType"];
    
    if([_filterDic.allKeys containsObject:@"startDate"]){
        [paramDic setObject:_filterDic[@"startDate"] forKey:@"startTime"];
    }
    if([_filterDic.allKeys containsObject:@"endDate"]){
        [paramDic setObject:_filterDic[@"endDate"] forKey:@"endTime"];
    }
    if([_filterDic.allKeys containsObject:@"UnReadMsg"]){
        // 0未读 1已读
        [paramDic setObject:_filterDic[@"UnReadMsg"] forKey:@"isRead"];
    }
    
    [paramDic setObject:[NSNumber numberWithInt:_page] forKey:@"pageNumber"];
    [paramDic setObject:[NSNumber numberWithInt:_length] forKey:@"pageSize"];
    
    NSDictionary *param = @{@"param":[Utils convertToJsonData:paramDic]};
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/public/getMessageByType", Main_Url];
    
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        [_msgTableView.mj_header endRefreshing];
        [_msgTableView.mj_footer endRefreshing];
        if([responseObject[@"code"] isEqualToString:@"1"]){
            if(_page == 1){
                [_msgData removeAllObjects];
            }
            
            if(responseObject[@"responseData"] == nil || [responseObject[@"responseData"] isKindOfClass:[NSNull class]]){
                return ;
            }
            
            /*
            if(isNotifition){
                NSDictionary *status = responseObject[@"responseData"][@"status"];
                NSNumber *UNREAD_SUM = status[@"UNREAD_SUM"];
                
                NSMutableDictionary *msgDic = @{}.mutableCopy;
                if(_messageType == LoginMessage){
                    [msgDic setObject:UNREAD_SUM forKey:@"LoginUnreadNum"];
                }else if(_messageType == WranMessage){
                    [msgDic setObject:UNREAD_SUM forKey:@"WarnUnreadNum"];
                }else if(_messageType == BillMessage){
                    [msgDic setObject:UNREAD_SUM forKey:@"BillUnreadNum"];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadViewMsgCount" object:nil userInfo:msgDic];
            }
             */
            
            NSArray *msgAry = responseObject[@"responseData"][@"items"];
            if(msgAry.count > 0){
                _msgTableView.mj_footer.state = MJRefreshStateIdle;
                _msgTableView.mj_footer.hidden = NO;
            }else {
                _msgTableView.mj_footer.state = MJRefreshStateNoMoreData;
                _msgTableView.mj_footer.hidden = YES;
            }
            
            [msgAry enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                MessageModel *msgModel = [[MessageModel alloc] initWithDataDic:obj];
                [_msgData addObject:msgModel];
            }];
        }else {
            [self showHint:responseObject[@"message"]];
        }
        noDataView.hidden = NO;
        [_msgTableView cyl_reloadData];
    } failure:^(NSError *error) {
        [_msgTableView.mj_header endRefreshing];
        [_msgTableView.mj_footer endRefreshing];
        noDataView.hidden = NO;
        [_msgTableView cyl_reloadData];
    }];
}

#pragma mark 更新未读消息数
- (void)_loadMsgData {
    NSString *messageType = @"";
    if(_messageType == LoginMessage){
        messageType = @"01";
    }else if(_messageType == WranMessage){
        messageType = @"02";
    }else if(_messageType == BillMessage){
        messageType = @"03";
    }
    
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:KLoginUserName];
    NSString *urlStr = [NSString stringWithFormat:@"%@/public/getUnreadMessage?appType=%@&loginName=%@&messageType=%@",Main_Url, @"admin", username, messageType];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        NSDictionary *data = responseObject;
        if ([data[@"code"] isEqualToString:@"1"]) {
            NSNumber *msgNum = responseObject[@"responseData"];
            if(msgNum != nil && ![msgNum isKindOfClass:[NSNull class]] && msgNum.integerValue >= 0){
                // 更新page title
                NSMutableDictionary *msgDic = @{}.mutableCopy;
                if(_messageType == LoginMessage){
                    [msgDic setObject:msgNum forKey:@"LoginUnreadNum"];
                }else if(_messageType == WranMessage){
                    [msgDic setObject:msgNum forKey:@"WarnUnreadNum"];
                }else if(_messageType == BillMessage){
                    [msgDic setObject:msgNum forKey:@"BillUnreadNum"];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadViewMsgCount" object:nil userInfo:msgDic];
            }
        }
        
    } failure:^(NSError *error) {
    }];
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    noDataView.hidden = NO;
    return noDataView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

#pragma mark UItableView 协议
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _msgData.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageModel *messageModel = _msgData[indexPath.row];
    CGFloat height = 70;
    height += [CalculateHeight heightForString:messageModel.PUSH_CONTENT fontSize:16 andWidth:KScreenWidth - 18];
    return height;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];
    cell.messageModel = _msgData[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MessageModel *msgModel = _msgData[indexPath.row];
    
    // 跳转详情
    MsgDetailViewController *msgDelVC = [[UIStoryboard storyboardWithName:@"Personal" bundle:nil] instantiateViewControllerWithIdentifier:@"MsgDetailViewController"];
    msgDelVC.messageModel = msgModel;
    [self.navigationController pushViewController:msgDelVC animated:YES];
    
    if(msgModel.IS_READ.integerValue == 1){
        return; // 已读消息
    }
    // 消息置为已读
    NSString *urlStr = [NSString stringWithFormat:@"%@/public/readMessage?pushId=%@", Main_Url, msgModel.PUSH_ID];
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        if([responseObject[@"code"] isEqualToString:@"1"]){
            msgModel.IS_READ = @"1";
            [_msgTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
            [self _loadMsgData];
        }else {
            NSString *msg = responseObject[@"message"];
            if(msg != nil && ![msg isKindOfClass:[NSNull class]] && msg.length > 0){
                [self showHint:responseObject[@"message"]];
            }
        }
    } failure:^(NSError *error) {
    }];
    
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    // 添加一个删除按钮
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除"handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        
        // 消息删除
        [self deleteMsg:indexPath];
    }];
    
    // 将设置好的按钮放到数组中返回
    return @[deleteRowAction];
}

- (void)deleteMsg:(NSIndexPath *)indexPath {
    MessageModel *msgModel = _msgData[indexPath.row];
    
    NSString *deleteUrl = [NSString stringWithFormat:@"%@/public/delMessage?pushId=%@", Main_Url, msgModel.PUSH_ID];
    [[NetworkClient sharedInstance] GET:deleteUrl dict:nil progressFloat:nil succeed:^(id responseObject) {
        if([responseObject[@"code"] isEqualToString:@"1"]){
            if(_msgData.count > indexPath.row){
                [_msgData removeObjectAtIndex:indexPath.row];
                [_msgTableView deleteRowsAtIndexPaths:@[indexPath]withRowAnimation:UITableViewRowAnimationAutomatic];
                [self _loadMsgData];
            }
        }else {
            [self showHint:responseObject[@"message"]];
        }
    } failure:^(NSError *error) {
        
    }];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MessageResSet" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MessageFilter" object:nil];
}

@end
