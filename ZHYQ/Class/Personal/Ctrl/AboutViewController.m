//
//  AboutViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/11/22.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "AboutViewController.h"

#import "PublicModel.h"

#import "YQRemindUpdatedView.h"
#import "VerListViewController.h"

@interface AboutViewController ()<YQRemindUpdatedViewDelegate>
{
    __weak IBOutlet NSLayoutConstraint *_topHeight;
    __weak IBOutlet NSLayoutConstraint *_bgImgTop;
    
    __weak IBOutlet NSLayoutConstraint *_logoHeight;
    __weak IBOutlet NSLayoutConstraint *_logoWidth;
    
    __weak IBOutlet NSLayoutConstraint *_buildHeight;
    __weak IBOutlet NSLayoutConstraint *_buildWidth;
    
    __weak IBOutlet NSLayoutConstraint *_imgheight;
    __weak IBOutlet NSLayoutConstraint *_imgWidth;
    
    __weak IBOutlet NSLayoutConstraint *_codeImgheight;
    __weak IBOutlet NSLayoutConstraint *_codeImgWidth;
    
    __weak IBOutlet UILabel *_versionNumLabel;
    UIView *view;
}
@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _topHeight.constant = _topHeight.constant*hScale;
    _bgImgTop.constant = _bgImgTop.constant*hScale;
    
    _logoHeight.constant = _logoHeight.constant*hScale;
    _logoWidth.constant = _logoWidth.constant*hScale;
    
    _buildHeight.constant = _buildHeight.constant*hScale;
    _buildWidth.constant = _buildWidth.constant*hScale;
    
    _imgheight.constant = _imgheight.constant*hScale;
    _imgWidth.constant = _imgWidth.constant*hScale;
    
    _codeImgheight.constant = _codeImgheight.constant*hScale;
    _codeImgWidth.constant = _codeImgWidth.constant*hScale;
    
//    [self loadVersData];
    
    [kNotificationCenter addObserver:self selector:@selector(isNeedRemaind:) name:@"isNeedRemaindNotification" object:nil];
    
    NSString *appVersionPath = [[NSBundle mainBundle] pathForResource:@"appVersion" ofType:@"plist"];
    NSDictionary *appVersionDic = [NSDictionary dictionaryWithContentsOfFile:appVersionPath];
    NSString *appVersion = appVersionDic[@"showVersion"];
    
    _versionNumLabel.text = [NSString stringWithFormat:@"版本号V%@",appVersion];
    
    [self _initView];
    
    BOOL isNeedRemain = [kUserDefaults boolForKey:KNeedRemain];
    if (isNeedRemain) {
        view.hidden = NO;
    }else{
        view.hidden = YES;
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"版本介绍" style:UIBarButtonItemStylePlain target:self action:@selector(intorduce)];
}
- (void)intorduce {
    VerListViewController *verListVC = [[VerListViewController alloc] init];
    [self.navigationController pushViewController:verListVC animated:YES];
}

-(void)isNeedRemaind:(NSNotification *)notification
{
    NSDictionary *dic = (NSDictionary *)notification.object;
    NSString *isNeedRemaind = dic[@"isNeedRemaind"];
    if ([isNeedRemaind isEqualToString:@"1"]) {
        view.hidden = NO;
        [kUserDefaults setBool:YES forKey:KNeedRemain];
    }else{
        view.hidden = YES;
        [kUserDefaults setBool:NO forKey:KNeedRemain];
    }
}

- (void)_initView {
    self.title = @"关于我们";
    
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#e2e2e2"];
    self.tableView.contentInset = UIEdgeInsetsMake(5, 0, 0, 0);
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIButton *remindNewVersionBtn = [[UIButton alloc] init];
    remindNewVersionBtn.frame = CGRectMake(0, _versionNumLabel.bottom+15, 150, 30);
    [remindNewVersionBtn setTitle:@"当前为最新版本" forState:UIControlStateNormal];
    [remindNewVersionBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [remindNewVersionBtn setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
    [remindNewVersionBtn addTarget:self action:@selector(newVersionBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:remindNewVersionBtn];
    
    if ([_isNeedUpdate isEqualToString:@"1"]) {
        remindNewVersionBtn.frame = CGRectMake(0, _versionNumLabel.bottom+15, 90, 30);
        [remindNewVersionBtn setTitle:@"发现新版本" forState:UIControlStateNormal];
        [remindNewVersionBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
        [remindNewVersionBtn setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
        
        view = [[UIView alloc] initWithFrame:CGRectMake(-8, 12, 6, 6)];
        view.backgroundColor = [UIColor redColor];
        view.layer.cornerRadius = 3;
        view.clipsToBounds = YES;
        [remindNewVersionBtn addSubview:view];
        remindNewVersionBtn.enabled = YES;
    }else {
        remindNewVersionBtn.enabled = NO;
    }
    
    remindNewVersionBtn.centerX = KScreenWidth/2;
    
//    if ([_isNeedUpdate isEqualToString:@"1"]) {
//        UIButton *rightBtn = [[UIButton alloc] init];
//        rightBtn.frame = CGRectMake(0, 0, 70, 40);
//        [rightBtn setTitle:@"发现新版本" forState:UIControlStateNormal];
//        [rightBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
//        [rightBtn addTarget:self action:@selector(_rightBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
//        UIBarButtonItem *rightBtnItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
//        self.navigationItem.rightBarButtonItem = rightBtnItem;
//
//        view = [[UIView alloc] initWithFrame:CGRectMake(-8, 8, 8, 8)];
//        view.backgroundColor = [UIColor redColor];
//        view.layer.cornerRadius = 4;
//        view.clipsToBounds = YES;
//        [rightBtn addSubview:view];
//    }
}
- (void)_leftBarBtnItemClick {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_rightBarBtnItemClick
{
    
}

- (void)newVersionBtnAction
{
    view.hidden = YES;
    [kUserDefaults setBool:NO forKey:KNeedRemain];
    YQRemindUpdatedView *pView = [[YQRemindUpdatedView alloc] initWithTitle:[NSString stringWithFormat:@"V%@新版本更新", _model.versionNum] message:_model.versionInfo delegate:self leftButtonTitle:@"暂不更新" rightButtonTitle:@"立即更新"];
    pView.delegate = self;
    pView.isMust = @"0";
    [pView show];
}

#pragma mark YQRemindUpdatedView Delegate
-(void)remaindViewBtnClick:(buttonType)btn
{
    if (btn == sureButton) {
        if (_model.appUrl != nil && ![_model.appUrl isKindOfClass:[NSNull class]]) {
            NSString *appUrl = _model.appUrl;
            NSString *urlStr = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@", appUrl];    // @"https://dn-transfar.qbox.me/zhihui_admin.plist"
            
            UIApplication *application = [UIApplication sharedApplication];
            NSURL *URL = [NSURL URLWithString:urlStr];
            if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
                [application openURL:URL options:@{} completionHandler:^(BOOL success) {
                    NSLog(@"Open %@: %d",urlStr,success);
                    //退出应用程序
                    exit(0);
                }];
                
            } else {
                BOOL success = [application openURL:URL];
                NSLog(@"Open %@: %d",urlStr,success);
            }
            
        }else{
            [self showHint:@"更新失败!"];
        }
    }
}

#pragma mark 加载版本信息
- (void)loadVersData {
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
            if(model.versionNum != nil && ![model.versionNum isKindOfClass:[NSNull class]]){
                _versionNumLabel.text = [NSString stringWithFormat:@"版本号V%@", model.versionNum];
            }else {
                _versionNumLabel.text = @"";
            }
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
