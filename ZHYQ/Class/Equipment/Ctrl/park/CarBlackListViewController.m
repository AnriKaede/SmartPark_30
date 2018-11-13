//
//  CarBlackListViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/9.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "CarBlackListViewController.h"
#import "CarBlackListTabCell.h"
#import "CarIllegeaCell.h"

#import "YQSearchBar.h"

#import "CarBlackListModel.h"

#import "IllegaListModel.h"
#import "NoDataView.h"

#import "UIViewController+WLAlert.h"

#import "NoDataView.h"

@interface CarBlackListViewController ()<UITableViewDelegate,UITableViewDataSource, ChangeStateDelegate, UISearchBarDelegate, CYLTableViewPlaceHolderDelegate>
{
    NSMutableArray *_dataArr;
    
    int _page;
    int _length;
    
    UITextField *_carnoTF;
    UITextField *_contentTF;
}

@property (nonatomic,strong) UITableView *tabView;

@end

@implementation CarBlackListViewController

-(UITableView *)tabView
{
    if (_tabView == nil) {
        _tabView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tabView.dataSource = self;
        //        _tabView.bounces = NO;
        _tabView.delegate = self;
        _tabView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tabView.showsVerticalScrollIndicator = NO;
        _tabView.showsHorizontalScrollIndicator = NO;
        _tabView.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    }
    return _tabView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _dataArr = @[].mutableCopy;
    
    _page = 0;
    _length = 10;
    
    [self _initNavItems];
    
    [self _initView];
    
    [self _loadBackListData:@"01"];
}

-(void)_initNavItems
{
    self.title = @"车辆黑名单";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    /*
    _rightBtn = [[UIButton alloc] init];
    _rightBtn.frame = CGRectMake(0, 0, 60, 40);
    [_rightBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [_rightBtn setTitle:@"黑名单" forState:UIControlStateNormal];
    [_rightBtn addTarget:self action:@selector(rightFilter) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:_rightBtn];
     self.navigationItem.rightBarButtonItem = rightItem;
     */
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"meetroon_add_scene"] style:UIBarButtonItemStylePlain target:self action:@selector(addBlackAction)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addBlackAction)];
}

-(void)_initView
{
    self.view.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    
    UITapGestureRecognizer *endEditTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditAction)];
    [self.view addGestureRecognizer:endEditTap];
    
    YQSearchBar *searchBar = [[YQSearchBar alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 44)];
    searchBar.placeholder = @"请输入车牌号";
    [searchBar setImage:[UIImage imageNamed:@"search_icon"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    searchBar.delegate = self;
    searchBar.returnKeyType = UIReturnKeySearch;
    [self.view addSubview:searchBar];
    
    [self.view addSubview:self.tabView];
    [_tabView registerNib:[UINib nibWithNibName:@"CarBlackListTabCell" bundle:nil] forCellReuseIdentifier:@"CarBlackListTabCell"];
    [_tabView registerNib:[UINib nibWithNibName:@"CarIllegeaCell" bundle:nil] forCellReuseIdentifier:@"CarIllegeaCell"];
    _tabView.frame = CGRectMake(0, CGRectGetMaxY(searchBar.frame), KScreenWidth, KScreenHeight-64-CGRectGetMaxY(searchBar.frame));
    
    _tabView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _page = 0;
        [self _loadBackListData:@"01"];
    }];
    // 上拉刷新
    _tabView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _page ++;
        [self _loadBackListData:@"01"];
    }];
//    _tabView.mj_footer.automaticallyHidden = NO;
    _tabView.mj_footer.hidden = YES;
}

- (void)endEditAction {
    [self.view endEditing:YES];
}

#pragma mark 获取黑名单车辆
-(void)_loadBackListData:(NSString *)illegalStatus {
    NSString *urlStr = [NSString stringWithFormat:@"%@/operaIllegal/getIllegals",ParkMain_Url]; // getIllegals 这个接口加一个参数 illegalStatus  只查黑名单就传01
    NSMutableDictionary *params = @{}.mutableCopy;
    [params setObject:KParkId forKey:@"parkId"];
    [params setValue:[NSNumber numberWithInt:_page * _length] forKey:@"start"];
    [params setValue:[NSNumber numberWithInt:_length] forKey:@"length"];
    if(illegalStatus != nil && illegalStatus.length > 0){
        [params setObject:illegalStatus forKey:@"illegalStatus"];
    }
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        [self removeNoDataImage];
        [_tabView.mj_header endRefreshing];
        [_tabView.mj_footer endRefreshing];
        
        if([responseObject[@"success"] boolValue]){
            NSDictionary *dic = responseObject[@"data"];
            NSArray *arr = dic[@"data"];
            if(_page == 0){
                [_dataArr removeAllObjects];
            }
            if(arr.count > _length-1){
                _tabView.mj_footer.state = MJRefreshStateIdle;
                _tabView.mj_footer.hidden = NO;
            }else {
                _tabView.mj_footer.state = MJRefreshStateNoMoreData;
                _tabView.mj_footer.hidden = YES;
            }
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CarBlackListModel *model = [[CarBlackListModel alloc] initWithDataDic:obj];
                [_dataArr addObject:model];
            }];
            
        }
        [self.tabView cyl_reloadData];
    } failure:^(NSError *error) {
        [_tabView.mj_header endRefreshing];
        [_tabView.mj_footer endRefreshing];
        if(_dataArr.count <= 0){
            [self showNoDataImage];
        }else {
            [self showHint:KRequestFailMsg];
        }
    }];
}
// 无网络重载
- (void)reloadTableData {
    [self _loadBackListData:@"01"];
}

#pragma mark 无数据协议
- (UIView *)makePlaceHolderView {
    NoDataView *noDateView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight-64-49)];
    return noDateView;
}
- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES;
}

#pragma mark tableview delegate and datasource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _dataArr.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CarBlackListTabCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CarBlackListTabCell" forIndexPath:indexPath];
//    if(indexPath == _selIndexPath){
//        cell.headLineView.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
//    }else {
//        cell.headLineView.backgroundColor = [UIColor whiteColor];
//    }
    cell.changeStatedelegate = self;
    cell.model = _dataArr[indexPath.section];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CarBlackListModel *model = _dataArr[indexPath.section];
    if(model.illegalContent == nil || [model.illegalContent isKindOfClass:[NSNull class]] || model.illegalContent.length <= 0){
        return 70;
    }else {
        return 100;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark 改变状态协议
- (void)changeState:(CarBlackListModel *)carBlackListModel {
    NSString *title = @"";
    NSString *msg = @"";
    title = @"恢复至白名单？";
    msg = [NSString stringWithFormat:@"确定将%@恢复至白名单?恢复后，车辆可正常进入园区车库。", carBlackListModel.illegalCarno];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *state;
        state = @"02";
        [self requestChangeState:carBlackListModel withState:state];
    }];
    [alert addAction:cancel];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark 改变车辆状态
- (void)requestChangeState:(CarBlackListModel *)carBlackListModel withState:(NSString *)state {
    NSString *urlStr = [NSString stringWithFormat:@"%@/operaIllegal/updateIllegal",ParkMain_Url];
    NSMutableDictionary *param = @{}.mutableCopy;
    [param setObject:carBlackListModel.illegalId forKey:@"illegalId"];
    [param setObject:state forKey:@"status"];
    [param setObject:[kUserDefaults objectForKey:KLoginUserName] forKey:@"memberName"];
    [[NetworkClient sharedInstance] POST:urlStr dict:param progressFloat:nil succeed:^(id responseObject) {
        if([responseObject[@"success"] boolValue]){
            
            // 恢复白名单 从黑名单列表中删除
            NSInteger indexSeccion = [_dataArr indexOfObject:carBlackListModel];
            [_dataArr removeObject:carBlackListModel];
//            [_tabView deleteSection:indexSeccion withRowAnimation:UITableViewRowAnimationFade];
            [_tabView reloadData];
            
            // 记录日志
            [self logRecord:[NSString stringWithFormat:@"%@恢复白名单", carBlackListModel.illegalCarno] withUrl:@"operaIllegal/updateIllegal"];
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)logRecord:(NSString *)carNoOperate withUrl:(NSString *)url {
    NSMutableDictionary *logDic = @{}.mutableCopy;
    [logDic setObject:carNoOperate forKey:@"operateName"];//操作动作名 说明
    [logDic setObject:carNoOperate forKey:@"operateDes"];//操作描述 说明
    [logDic setObject:url forKey:@"operateUrl"];//操作url
//    [logDic setObject:<#(nonnull id)#> forKey:@"operateLocation"];//操作地点
//    [logDic setObject:<#(nonnull id)#> forKey:@"operateValue"];//操作值(如音量大小)
//    [logDic setObject:<#(nonnull id)#> forKey:@"operateDeviceId"];//操作设备ID tagid
    [logDic setObject:@"停车" forKey:@"operateDeviceName"];//操作设备名  模块
//    [logDic setObject:<#(nonnull id)#> forKey:@"expand1"];//扩展字段 (暂未用到)    操作前值比如音量
    
    [LogRecordObj recordLog:logDic];
}

-(void)_leftBarBtnItemClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 增加黑名单
- (void)addBlackAction {
    /*
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"添加黑名单" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"车牌号";
        _carnoTF = textField;
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"备注";
        _contentTF = textField;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if(_carnoTF.text == nil || _carnoTF.text.length <= 0){
            [self showHint:@"请输入车牌"];
            return ;
        }
        if(_contentTF.text == nil || _contentTF.text.length <= 0){
            [self showHint:@"请填写备注"];
            return ;
        }
        [self addBlackList:_carnoTF.text withContent:_contentTF.text];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
     */
    
    [self showTextFieldAlert:@"添加黑名单" withCarnoPlaceholder:@"车牌号码" withInfoPlaceholder:@"备注" withCancelMsg:@"取消" withCancelBlock:^{
    } withCertainMsg:@"确定" withCertainBlock:^(NSString *carno, NSString *info) {
        [self addBlackList:carno withContent:info];
    } isMsgAlert:NO];
}

- (void)addBlackList:(NSString *)carno withContent:(NSString *)content {
    NSString *blackUrl = [NSString stringWithFormat:@"%@/operaIllegal/addIllegal", ParkMain_Url];
    NSMutableDictionary *param = @{}.mutableCopy;
    [param setObject:carno forKey:@"illegalCarno"];
    [param setObject:[[NSUserDefaults standardUserDefaults] objectForKey:KLoginUserName] forKey:@"memberName"];
    [param setObject:content forKey:@"illegalContent"];
    [[NetworkClient sharedInstance] POST:blackUrl dict:param progressFloat:nil succeed:^(id responseObject) {
        if([responseObject[@"success"] boolValue]){
            _page = 0;
            [self _loadBackListData:@"01"];
            
            // 添加黑名单 记录日志
            [self logRecord:[NSString stringWithFormat:@"%@添加黑名单", carno] withUrl:@"operaIllegal/addIllegal"];
        }
        [self showHint:responseObject[@"message"]];
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark SearchBar 协议
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self endEditAction];
    if(searchBar.text <= 0){
        [self showHint:@"请输入车牌"];
        return;
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/operaIllegal/getIllegalNumByCarno",ParkMain_Url];
    NSMutableDictionary *params = @{}.mutableCopy;
    [params setObject:searchBar.text forKey:@"carno"];
    [params setObject:KParkId forKey:@"parkId"];
    
    [[NetworkClient sharedInstance] POST:urlStr dict:params progressFloat:nil succeed:^(id responseObject) {
        if([responseObject[@"success"] boolValue]){
            [_dataArr removeAllObjects];
            NSDictionary *dic = responseObject[@"data"];
            NSArray *operaIllegal = dic[@"data"];
            if(operaIllegal != nil && ![operaIllegal isKindOfClass:[NSNull class]]){
                [operaIllegal enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    CarBlackListModel *model = [[CarBlackListModel alloc] initWithDataDic:obj];
                    [_dataArr addObject:model];
                }];
                [self.tabView cyl_reloadData];
            }
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
