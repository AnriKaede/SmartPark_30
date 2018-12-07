//
//  PersonalViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/10/26.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "PersonalViewController.h"
#import "SetHeaderView.h"
#import "SetFooterView.h"

#import "EditInfoTableViewController.h"
#import "OperateLogViewController.h"
#import "ResetPswTableViewController.h"
#import "WorkListCenViewController.h"
#import "FaceWranViewController.h"

#import "AboutViewController.h"

#import "LoginViewController.h"

#import <SDImageCache.h>
#import "PublicModel.h"

#import "Utils.h"

#define listCellHeight 240

@interface PersonalViewController ()<ContactCtrlDelegate>
{
    SetHeaderView *headerView;
    PublicModel *_model;
    
    NSString *isNeedUpdate;
    
    __weak IBOutlet UIView *remaindView;
}

@property (weak, nonatomic) IBOutlet UILabel *cacheSizeLab;
@property (weak, nonatomic) IBOutlet UILabel *versionLab;

@end

@implementation PersonalViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 计算缓存
    [self queryCache];
    
    [self showVersionAlert];
}

#pragma mark 加载更新信息
- (void)showVersionAlert {
    
    NSString *appVersionPath = [[NSBundle mainBundle] pathForResource:@"appVersion" ofType:@"plist"];
    NSDictionary *appVersionDic = [NSDictionary dictionaryWithContentsOfFile:appVersionPath];
    NSString *appVersion = appVersionDic[@"appVersion"];
    
    NSString *loginName = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:KLoginUserName]];
    
    NSString *versionUrl = [NSString stringWithFormat:@"%@/public/getVersion?appType=admin&osType=ios&versionCust=%@&version=%@", Main_Url, loginName, appVersion];
    [[NetworkClient sharedInstance] GET:versionUrl dict:nil progressFloat:nil succeed:^(id responseObject) {
        if([responseObject[@"code"] isEqualToString:@"1"]){
            NSDictionary *responseData = responseObject[@"responseData"];
            if(responseData == nil || [responseData isKindOfClass:[NSNull class]]){
                return ;
            }
            PublicModel *model = [[PublicModel alloc] initWithDataDic:responseData];
            _model = model;
            if(model.appCode != nil && ![model.appCode isKindOfClass:[NSNull class]] && model.appCode.integerValue > appVersion.integerValue){
                BOOL isNeedRemain = [kUserDefaults boolForKey:KNeedRemain];
                if (isNeedRemain) {
                    remaindView.hidden = NO;
                    remaindView.layer.cornerRadius = 4;
                    remaindView.clipsToBounds = YES;
                    isNeedUpdate = @"1";
                }else{
                    remaindView.hidden = YES;
                    remaindView.layer.cornerRadius = 4;
                    remaindView.clipsToBounds = YES;
                    isNeedUpdate = @"1";
                }
            }else{
                remaindView.hidden = YES;
                isNeedUpdate = @"0";
            }
            
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self _initView];
    
    [kNotificationCenter addObserver:self selector:@selector(loginMessage:) name:@"loginNotification" object:nil];
    
    [kNotificationCenter addObserver:self selector:@selector(logoutNotion) name:@"logoutNotion" object:nil];
    
}

- (void)logoutNotion {
    [self.tableView reloadData];
}

-(void)_initView
{
    self.cacheSizeLab.textColor = [UIColor colorWithHexString:@"FF6C12"];
    self.versionLab.textColor = [UIColor colorWithHexString:@"1B82D1"];
}

- (void)queryCache {
    float allCache = [self caculateCache];
    NSString *clearCacheName = allCache >= 1 ? [NSString stringWithFormat:@"%.2fM",allCache] : [NSString stringWithFormat:@"%.2fK",allCache * 1024];
    _cacheSizeLab.text = clearCacheName;
}

- (float)caculateCache {
    float SDTmpCache = [[SDImageCache sharedImageCache] getSize]/(1024*1024.2f);
    
    return SDTmpCache;
}

#pragma mark UITableView 协议
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 2 && ![[NSUserDefaults standardUserDefaults] boolForKey:KIsRepairman]){
        return 0.1;
    }
    if(indexPath.row == 0){
        return 0.1;
    }
    return 60;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    headerView = [[SetHeaderView alloc] init];
    if (kDevice_Is_iPhoneX) {
        headerView.frame = CGRectMake(0, 0, KScreenWidth, 160);
    }else
    {
        headerView.frame = CGRectMake(0, 0, KScreenWidth, 145);
    }
//    NSString *iconUrl = [kUserDefaults objectForKey:@"headImag"];
    NSString *nameStr = [kUserDefaults objectForKey:@"userName"];
    if (nameStr == nil) {
        nameStr = @"未登录";
    }
    headerView.iconView.image = [UIImage imageNamed:@"tongfu_logo"];
    headerView.nameLab.text = nameStr;
    NSString *roleName = [kUserDefaults objectForKey:@"roleName"];
    if(roleName != nil && ![roleName isKindOfClass:[NSNull class]] && roleName.length > 0){
        headerView.signLab.hidden = NO;
        headerView.signLab.text = roleName;
    }else {
        headerView.signLab.hidden = YES;
    }
    UITapGestureRecognizer *infoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(infoAction)];
    [headerView addGestureRecognizer:infoTap];
    
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat height;
    if (kDevice_Is_iPhoneX) {
        height = 160;
    }else{
        height = 145;
    }
    return height;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    SetFooterView *footerView = [[SetFooterView alloc] init];
    if (kDevice_Is_iPhoneX) {
        footerView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight-180-listCellHeight);
    }else
    {
        footerView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight-145-listCellHeight);
    }
    footerView.delegate = self;
    return footerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat height;
    if (kDevice_Is_iPhoneX) {
        height = KScreenHeight-180-listCellHeight-60;
    }else{
        if([[NSUserDefaults standardUserDefaults] boolForKey:KIsRepairman]){
            height = KScreenHeight-145-listCellHeight-60;
        }else {
            height = KScreenHeight-145-listCellHeight;
        }
    }
    return height;
}

-(void)loadView
{
    [super loadView];
}

-(void)DismissContactsCtrl
{
    [Utils logoutRemoveDefInfo];
    
    [kNotificationCenter postNotificationName:@"loginOutNotification" object:nil userInfo:nil];
    [self.tableView reloadData];
    [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
        {
            if ([kUserDefaults boolForKey:KLoginState]) {
                // 人像告警
                FaceWranViewController *faceWranVC = [[FaceWranViewController alloc] init];
                faceWranVC.hidesBottomBarWhenPushed = YES;
                
                //拿到我们的LitterLCenterViewController，让它去push
                RootNavigationController* nav = (RootNavigationController*)self.mm_drawerController.centerViewController.childViewControllers.firstObject;
                [nav pushViewController:faceWranVC animated:NO];
            }else{
                RootNavigationController *loginVC = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginNavViewController"];
                [self presentViewController:loginVC animated:YES completion:nil];
            }
            //当我们push成功之后，关闭我们的抽屉
            [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
                //设置打开抽屉模式为MMOpenDrawerGestureModeNone，也就是没有任何效果。
                [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
            }];
            break;
        }
        case 1:
        {
            if ([kUserDefaults boolForKey:KLoginState]) {
                // 修改密码
                ResetPswTableViewController *resetPswVC = [[UIStoryboard storyboardWithName:@"Personal" bundle:nil] instantiateViewControllerWithIdentifier:@"ResetPswTableViewController"];
                resetPswVC.hidesBottomBarWhenPushed = YES;
                
                //拿到我们的LitterLCenterViewController，让它去push
                RootNavigationController* nav = (RootNavigationController*)self.mm_drawerController.centerViewController.childViewControllers.firstObject;
                [nav pushViewController:resetPswVC animated:NO];
            }else{
                RootNavigationController *loginVC = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginNavViewController"];
                [self presentViewController:loginVC animated:YES completion:nil];
            }
            //当我们push成功之后，关闭我们的抽屉
            [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
                //设置打开抽屉模式为MMOpenDrawerGestureModeNone，也就是没有任何效果。
                [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
            }];
            break;
        }
        case 2:
            {
                // 操作日志
                if ([kUserDefaults boolForKey:KLoginState]) {
                    OperateLogViewController *logVC = [[OperateLogViewController alloc] init];
                    logVC.hidesBottomBarWhenPushed = YES;
                    
                    //拿到我们的LitterLCenterViewController，让它去push
                    RootNavigationController* nav = (RootNavigationController*)self.mm_drawerController.centerViewController.childViewControllers.firstObject;
                    [nav pushViewController:logVC animated:NO];
                    //当我们push成功之后，关闭我们的抽屉
                    [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
                        //设置打开抽屉模式为MMOpenDrawerGestureModeNone，也就是没有任何效果。
                        [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
                    }];
                }else{
                    RootNavigationController *loginVC = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginNavViewController"];
                    [self presentViewController:loginVC animated:YES completion:nil];
                }
                break;
            }
            
        case 3:
        {
            // 维修工单
            if ([kUserDefaults boolForKey:KLoginState]) {
                // 修改密码
                WorkListCenViewController *workListCenVC = [[WorkListCenViewController alloc] init];
                workListCenVC.hidesBottomBarWhenPushed = YES;
                
                //拿到我们的LitterLCenterViewController，让它去push
                RootNavigationController* nav = (RootNavigationController*)self.mm_drawerController.centerViewController.childViewControllers.firstObject;
                [nav pushViewController:workListCenVC animated:NO];
            }else{
                RootNavigationController *loginVC = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginNavViewController"];
                [self presentViewController:loginVC animated:YES completion:nil];
            }
            //当我们push成功之后，关闭我们的抽屉
            [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
                //设置打开抽屉模式为MMOpenDrawerGestureModeNone，也就是没有任何效果。
                [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
            }];
            break;
        }
            
        case 4:
        {
            // 清除缓存
            [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
                [self showHint:[NSString stringWithFormat:@"清除缓存%@", _cacheSizeLab.text]];
                _cacheSizeLab.text = @"0.00K";
            }];
            break;
        }
        case 5:
        {
            // 关于我们
            AboutViewController *aboutVC = [[UIStoryboard storyboardWithName:@"Personal" bundle:nil] instantiateViewControllerWithIdentifier:@"AboutViewController"];
            aboutVC.hidesBottomBarWhenPushed = YES;
            aboutVC.isNeedUpdate = isNeedUpdate;
            aboutVC.model = _model;
            //拿到我们的LitterLCenterViewController，让它去push
            RootNavigationController* nav = (RootNavigationController*)self.mm_drawerController.centerViewController.childViewControllers.firstObject;
            [nav pushViewController:aboutVC animated:NO];
            //当我们push成功之后，关闭我们的抽屉
            [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
                //设置打开抽屉模式为MMOpenDrawerGestureModeNone，也就是没有任何效果。
                [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
            }];
            break;
        }
            
            
        default:
            break;
    }
}

#pragma mark 点击信息 进入编辑
- (void)infoAction {
    
    if ([kUserDefaults boolForKey:KLoginState]) {
        // 个人信息编辑
        EditInfoTableViewController *editInfoVC = [[UIStoryboard storyboardWithName:@"Personal" bundle:nil] instantiateViewControllerWithIdentifier:@"EditInfoTableViewController"];
        editInfoVC.hidesBottomBarWhenPushed = YES;
        
        //拿到我们的LitterLCenterViewController，让它去push
        RootNavigationController* nav = (RootNavigationController*)self.mm_drawerController.centerViewController.childViewControllers.firstObject;
        [nav pushViewController:editInfoVC animated:NO];
    }else{
        RootNavigationController *loginVC = [[UIStoryboard storyboardWithName:@"Login" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginNavViewController"];
        [self presentViewController:loginVC animated:YES completion:nil];
    }
    
    //当我们push成功之后，关闭我们的抽屉
    [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {
        //设置打开抽屉模式为MMOpenDrawerGestureModeNone，也就是没有任何效果。
        [self.mm_drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    }];
}

#pragma mark 登录用户信息传递
-(void)loginMessage:(NSNotification *)notification
{
    [self.tableView reloadData];
    
    NSString *iconUrl = [kUserDefaults objectForKey:@"headImag"];
    NSString *nameStr = [kUserDefaults objectForKey:@"userName"];
    NSString *roleName = [kUserDefaults objectForKey:@"roleName"];
    if(roleName != nil && ![roleName isKindOfClass:[NSNull class]] && roleName.length > 0){
        headerView.signLab.hidden = NO;
        headerView.signLab.text = roleName;
    }else {
        headerView.signLab.hidden = YES;
    }
//    [headerView.iconView sd_setImageWithURL:[NSURL URLWithString:iconUrl] placeholderImage:[UIImage imageNamed:@"_member_icon"]];
    headerView.iconView.image = [UIImage imageNamed:@"tongfu_logo"];
    headerView.nameLab.text = nameStr;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"logoutNotion" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loginNotification" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
