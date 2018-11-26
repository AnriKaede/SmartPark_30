//
//  MsgPostViewController.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/10.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "MsgPostViewController.h"
#import "YQInputView.h"
#import "LEDpostMsgTableViewCell.h"
#import "YQPhotoPickerView.h"
#import "YQEditImageViewController.h"

#import "ChooseLedTableViewCell.h"
#import "PostTimeTableViewCell.h"
#import "LEDmsgTitleTableViewCell.h"
#import "LEDDetailViewController.h"
#import "ClockTimeCell.h"
#import "LedListModel.h"
#import "LEDFormworkViewController.h"
#import "LEDSendSucView.h"

#import "FaceHtmlView.h"

#define IMAGE_SIZE (KScreenWidth - 60)/4

#import "WGCommon.h"
#define SCREEN_WIDTH  ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

#define kEditorURL @"richText_editor"

@interface MsgPostViewController ()<UITextViewDelegate,UITableViewDelegate,UITableViewDataSource, ChooseLedDeleagte,UIWebViewDelegate,KWEditorBarDelegate,KWFontStyleBarDelegate, SendLedSucDelegate>
{
    NSMutableArray *_ledData;
    BOOL _isSendSuc;
    LEDSendSucView *_sendSucView;
    
    NSString *_postMsgContent;
}
/* 文本输入框*/
//@property(nonatomic, strong) YQInputView *inputV;
//@property(nonatomic, strong) FaceHtmlView *htmlView;
/* UITableView*/
@property(nonatomic, strong) UITableView *tabelV;
/* 选择图片*/
@property(nonatomic, strong) YQPhotoPickerView *photoPickerV;
/* 图片编辑起*/
@property(nonatomic, strong) YQEditImageViewController *editVC;
/* 当前选择的图片*/
@property(nonatomic, strong) NSMutableArray *imageDataSource;

@property (nonatomic,strong) UIView *headerView;

@property (nonatomic,strong) UIWebView *webView;
@property (nonatomic,strong) KWEditorBar *toolBarView;
@property (nonatomic,strong) KWFontStyleBar *fontBar;
@property (nonatomic,strong) UIButton *formworkBt;

@end

@implementation MsgPostViewController

-(UIView *)headerView
{
    if (_headerView == nil) {
        _headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 106)];
        _headerView.backgroundColor = [UIColor clearColor];

        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100.0*hScale, 50.0*hScale)];
        [btn addTarget:self action:@selector(postLEDMsgClick:) forControlEvents:UIControlEventTouchUpInside];
        btn.layer.cornerRadius = 4.0*hScale;
        [btn setTitle:@"确定提交" forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [btn setTitleColor:[UIColor colorWithHexString:@"#1B82D1"] forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF"];
        btn.clipsToBounds = YES;
        btn.layer.borderWidth = 0.5;
        btn.layer.borderColor = [UIColor colorWithHexString:@"#6E6E6E"].CGColor;
        [_headerView addSubview:btn];
        btn.center = _headerView.center;
    }
    return _headerView;
}
- (KWEditorBar *)toolBarView{
    if (!_toolBarView) {
        _toolBarView = [KWEditorBar editorBar];
        _toolBarView.frame = CGRectMake(0,SCREEN_HEIGHT - KWEditorBar_Height - kTopHeight, KScreenWidth, KWEditorBar_Height);
        _toolBarView.backgroundColor = COLOR(237, 237, 237, 1);
    }
    return _toolBarView;
}
- (KWFontStyleBar *)fontBar{
    if (!_fontBar) {
        _fontBar = [[KWFontStyleBar alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.toolBarView.frame) - KWFontBar_Height - KWEditorBar_Height - kTopHeight, KScreenWidth, KWFontBar_Height)];
        _fontBar.delegate = self;
        [_fontBar.heading2Item setSelected:YES];
        
    }
    return _fontBar;
}
- (UIWebView *)webView{
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth - 0, 250)];
        _webView.delegate = self;
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSURL *baseURL = [NSURL fileURLWithPath:path];
        NSString * htmlPath = [[NSBundle mainBundle] pathForResource:kEditorURL                                                              ofType:@"html"];
        NSString * htmlCont = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
        [_webView loadHTMLString:htmlCont baseURL:baseURL];
        _webView.scrollView.bounces=NO;
        _webView.hidesInputAccessoryView = YES;
        //        _webView.detectsPhoneNumbers = NO;
        
    }
    return _webView;
}
- (UIButton *)formworkBt {
    if(!_formworkBt){
        _formworkBt = [UIButton buttonWithType:UIButtonTypeCustom];
        _formworkBt.frame = CGRectMake(KScreenWidth - 80, 218, 68, 23);
        _formworkBt.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
        _formworkBt.layer.cornerRadius = 4;
        _formworkBt.titleLabel.font = [UIFont systemFontOfSize:14];
        [_formworkBt setTitle:@"使用模板" forState:UIControlStateNormal];
        [_formworkBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_formworkBt addTarget:self action:@selector(_rightBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _formworkBt;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _ledData = @[].mutableCopy;
    
    [self viewConfig];
    
    [self _initNavItems];
    
    [self _loadLedData];
}

-(void)_initNavItems
{
    self.title = @"发布新消息";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIButton *rightBtn = [[UIButton alloc] init];
    rightBtn.frame = CGRectMake(0, 0, 40, 40);
    [rightBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
    [rightBtn setImage:[UIImage imageNamed:@"led_nav_formwork"] forState:UIControlStateNormal];
    [rightBtn setTitle:@"内容模板" forState:UIControlStateNormal];
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    [rightBtn addTarget:self action:@selector(_rightBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTitleEdgeInsets:UIEdgeInsetsMake(rightBtn.imageView.frame.size.height ,-rightBtn.imageView.frame.size.width, -5,0.0)];
    [rightBtn setImageEdgeInsets:UIEdgeInsetsMake(-10, 20,0.0, -rightBtn.titleLabel.bounds.size.width)];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
//    self.navigationItem.rightBarButtonItem = rightItem;
    
    UITapGestureRecognizer *editTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditAction)];
    [self.view addGestureRecognizer:editTap];
}
- (void)endEditAction {
    [self.view endEditing:YES];
}

-(void)_leftBarBtnItemClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)_rightBarBtnItemClick {
    LEDFormworkViewController *LEDDetailVC = [[LEDFormworkViewController alloc] init];
    [self.navigationController pushViewController:LEDDetailVC animated:YES];
}

- (void)viewConfig {
    [self.view addSubview:self.toolBarView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    self.toolBarView.delegate = self;
    [self.toolBarView addObserver:self forKeyPath:@"transform" options:
     NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    
    _tabelV = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64) style:UITableViewStyleGrouped];
    _tabelV.delegate = self;
    _tabelV.dataSource = self;
    [_tabelV registerNib:[UINib nibWithNibName:@"ChooseLedTableViewCell" bundle:nil] forCellReuseIdentifier:@"ChooseLedTableViewCell"];
    [_tabelV registerNib:[UINib nibWithNibName:@"PostTimeTableViewCell" bundle:nil] forCellReuseIdentifier:@"PostTimeTableViewCell"];
    [_tabelV registerNib:[UINib nibWithNibName:@"LEDmsgTitleTableViewCell" bundle:nil] forCellReuseIdentifier:@"LEDmsgTitleTableViewCell"];
    [_tabelV registerNib:[UINib nibWithNibName:@"ClockTimeCell" bundle:nil] forCellReuseIdentifier:@"ClockTimeCell"];
    [_tabelV registerClass:[LEDpostMsgTableViewCell class] forCellReuseIdentifier:@"LEDpostMsgTableViewCell"];
    [self.view insertSubview:_tabelV atIndex:0];
    _tabelV.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tabelV.backgroundColor = [UIColor colorWithHexString:@"E2E2E2"];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    _sendSucView = [[LEDSendSucView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - kTopHeight)];
    _sendSucView.sendSucDelegate = self;
    [self.view addSubview:_sendSucView];
}
#pragma mark 点击保存模板协议
- (void)confirmWithName:(NSString *)name {
    [_sendSucView hidSendSucView];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/udpController/addTempInfo",Main_Url];
    NSMutableDictionary *addParam = @{}.mutableCopy;
    [addParam setObject:name forKey:@"Title"];
    [addParam setObject:_postMsgContent forKey:@"contents"];
    
    [self showHudInView:self.tableView hint:@""];
    [[NetworkClient sharedInstance] POST:urlStr dict:addParam progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
            [self showHint:responseObject[@"message"]];
        }
    } failure:^(NSError *error) {
        [self hideHud];
    }];
}

#pragma mark 获取屏列表
- (void)_loadLedData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/equipment/getLedScreenList",Main_Url];
    [self showHudInView:self.tableView hint:@""];
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            [_ledData removeAllObjects];
            NSArray *responseData = responseObject[@"responseData"][@"ledScreenList"];
            [responseData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                LedListModel *model = [[LedListModel alloc] initWithDataDic:obj];
                [_ledData addObject:model];
            }];
            [_tabelV reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        }
        
    } failure:^(NSError *error) {
        [self hideHud];
        [self showHint:KRequestFailMsg];
    }];
}

#pragma mark --------------UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 1){
        return 1;
    }else{
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        ChooseLedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChooseLedTableViewCell"];
        cell.ledData = _ledData;
        cell.chooseLedDeleagte = self;
        return cell;
    }else if(indexPath.section == 1) {
        LEDpostMsgTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"LEDpostMsgTableViewCell"];
        [cell addSubview:self.webView];
//        [cell addSubview:self.formworkBt];
        return cell;
    }else if(indexPath.section == 2) {
        PostTimeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostTimeTableViewCell"];
//        cell.delegate = self;
        return cell;
    }else{
        ClockTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ClockTimeCell"];
//        cell.delegate = self;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        CGFloat btHeight = (_ledData.count/3 + (_ledData.count%3>0 ? 1:0))*40;
        return 50 + btHeight;
    }else if(indexPath.section == 1){
        return 250;
    }else{
        return 60;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.0001f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(section == 1) {
        return 105.0f;
    }else {
        return 5.0f;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return self.headerView;
    }else{
        return [UIView new];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tabelV deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark LED发送新信息
-(void)postLEDMsgClick:(id)sender {
    NSMutableArray *selLeds = @[].mutableCopy;
    [_ledData enumerateObjectsUsingBlock:^(LedListModel *ledListModel, NSUInteger idx, BOOL * _Nonnull stop) {
        if(ledListModel.isSelect){
            [selLeds addObject:ledListModel];
        }
    }];
    if(selLeds.count <= 0){
        [self showHint:@"请选择发布屏"];
        return;
    }

    if([self.webView contentHtmlText].length <= 0){
        [self showHint:@"请输入内容"];
        return;
    }
    
    NSString *postMsg = [NSString stringWithFormat:@"<html style=\"color: red; font-size: 40px\"><head><meta charset=utf-8><title></title></head><body>%@</body></html>", [self.webView contentHtmlText]];
    
    postMsg = [postMsg stringByReplacingOccurrencesOfString:@"size=\"4\"" withString:@"size=\"7\""];
    postMsg = [postMsg stringByReplacingOccurrencesOfString:@"size=\"3\"" withString:@"size=\"6\""];
    postMsg = [postMsg stringByReplacingOccurrencesOfString:@"size=\"2\"" withString:@"size=\"5\""];
    
    NSLog(@"%@", postMsg);
    _postMsgContent = postMsg;
    
    // 不需要模板
    [selLeds enumerateObjectsUsingBlock:^(LedListModel *ledListModel, NSUInteger idx, BOOL * _Nonnull stop) {
        [self sendLedMsg:ledListModel withConnect:postMsg];
    }];
    
    /*
#warning 测试添加
    [_sendSucView showSendSucView];
    
    dispatch_group_t group = dispatch_group_create();
    
    _isSendSuc = YES;
    [selLeds enumerateObjectsUsingBlock:^(LedListModel *ledListModel, NSUInteger idx, BOOL * _Nonnull stop) {
        [self sendLedMsg:ledListModel withConnect:postMsg withQueue:group];
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 所有发送成功
//        if(_isSendSuc){
            [_sendSucView showSendSucView];
//        }
    });
     */
}

//- (void)sendLedMsg:(LedListModel *)ledListModel withConnect:(NSString *)connect withQueue:(id)group {
- (void)sendLedMsg:(LedListModel *)ledListModel withConnect:(NSString *)connect {
//    dispatch_group_enter(group);
    
    NSString *urlStr = [self postUrl:ledListModel];
    id searchParam = [self postParam:ledListModel withContent:connect];
    
    [self showHudInView:self.tableView hint:@""];
    [[NetworkClient sharedInstance] POST:urlStr dict:searchParam progressFloat:nil succeed:^(id responseObject) {
//        dispatch_group_leave(group);
        [self hideHud];
        if ([responseObject[@"code"] isEqualToString:@"1"]) {
            [self.navigationController popViewControllerAnimated:YES];
        }else {
            _isSendSuc = NO;
            if(responseObject[@"message"] != nil && ![responseObject[@"message"] isKindOfClass:[NSNull class]]){
                [self showHint:responseObject[@"message"]];
            }
        }
        
    } failure:^(NSError *error) {
//        dispatch_group_leave(group);
        [self hideHud];
        [self showHint:KRequestFailMsg];
    }];
}
- (NSString *)postUrl:(LedListModel *)ledListModel {
    if([ledListModel.type isEqualToString:@"1"]){
        return [NSString stringWithFormat:@"%@/roadLamp/lampVideoRoll",Main_Url];
    }else if([ledListModel.type isEqualToString:@"2"]){
        return [NSString stringWithFormat:@"%@/udpController/sendMsgToUdpSer",Main_Url];
    }
    return @"";
}
- (id)postParam:(LedListModel *)ledListModel withContent:(NSString *)content {
    if([ledListModel.type isEqualToString:@"1"]){
        NSMutableDictionary *searchParam = @{}.mutableCopy;
        [searchParam setObject:ledListModel.tagid forKey:@"tagId"];
        [searchParam setObject:@-1 forKey:@"num"];
        [searchParam setObject:content forKey:@"html"];
        [searchParam setObject:@"center" forKey:@"align"];
        NSString *jsonParam = [Utils convertToJsonData:searchParam];
        NSDictionary *params = @{@"param":jsonParam};
        return params;
    }else if([ledListModel.type isEqualToString:@"2"]){
        NSMutableDictionary *searchParam = @{}.mutableCopy;
        [searchParam setObject:ledListModel.deviceId forKey:@"deviceId"];
        [searchParam setObject:@"SENDHTML" forKey:@"instructions"];
        [searchParam setObject:content forKey:@"content"];
        return searchParam;
    }
    return @"";
}

#pragma mark 选择发送信息屏幕
- (void)chooseLed:(NSArray *)ledList {
    // 使用retain 不使用 copy ledList和原ledData 指向同一地址
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark html编辑器方法
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if([keyPath isEqualToString:@"transform"]){
        
        CGRect fontBarFrame = self.fontBar.frame;
        fontBarFrame.origin.y = CGRectGetMaxY(self.toolBarView.frame)- KWFontBar_Height - KWEditorBar_Height;
        self.fontBar.frame = fontBarFrame;
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark -webviewdelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"webViewDidFinishLoad");
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"NSError = %@",error);
    
    if([error code] == NSURLErrorCancelled){
        return;
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlString = request.URL.absoluteString;
    NSLog(@"loadURL = %@",urlString);
    
    [self handleEvent:urlString];
    
    if ([urlString rangeOfString:@"re-state-content://"].location != NSNotFound) {
        NSString *className = [urlString stringByReplacingOccurrencesOfString:@"re-state-content://" withString:@""];
        
        [self.fontBar updateFontBarWithButtonName:className];
        
        if ([self.webView contentText].length <= 0) {
            [self.webView showContentPlaceholder];
        }else{
            [self.webView clearContentPlaceholder];
        }
        
        if ([[className componentsSeparatedByString:@","] containsObject:@"unorderedList"]) {
            [self.webView clearContentPlaceholder];
        }
        
        
    }
    
    return YES;
}
#pragma mar - webView监听处理事件
- (void)handleEvent:(NSString *)urlString{
    if ([urlString hasPrefix:@"re-state-content://"]) {
        self.fontBar.hidden = NO;
        self.toolBarView.hidden = NO;
    }
    
    if ([urlString hasPrefix:@"re-state-title://"]) {
        self.fontBar.hidden = YES;
        self.toolBarView.hidden = YES;
    }
    
}


- (void)dealloc{
    @try {
        [self.toolBarView removeObserver:self forKeyPath:@"transform"];
    } @catch (NSException *exception)
    {
        NSLog(@"Exception: %@", exception);
    } @finally {
        // Added to show finally works as well
    }
}


/**
 *  是否显示占位文字
 */
- (void)isShowPlaceholder{
    if ([self.webView contentText].length <= 0)
    {
        [self.webView showContentPlaceholder];
    }else{
        [self.webView clearContentPlaceholder];
    }
}

#pragma mark -editorbarDelegate
- (void)editorBar:(KWEditorBar *)editorBar didClickIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:{
            //显示或隐藏键盘
            if (self.toolBarView.transform.ty < 0) {
                [self.webView hiddenKeyboard];
            }else{
                [self.webView showKeyboardContent];
            }
            
        }
            break;
        case 1:{
            //回退
            [self.webView stringByEvaluatingJavaScriptFromString:@"document.execCommand('undo')"];
        }
            break;
        case 2:{
            [self.webView stringByEvaluatingJavaScriptFromString:@"document.execCommand('redo')"];
        }
            break;
        case 3:{
            //显示更多区域
            editorBar.fontButton.selected = !editorBar.fontButton.selected;
            if (editorBar.fontButton.selected) {
                [self.view insertSubview:self.fontBar belowSubview:_sendSucView];
            }else{
                [self.fontBar removeFromSuperview];
            }
        }
            break;
            
        default:
            break;
    }
    
}
#pragma mark - fontbardelegate
- (void)fontBar:(KWFontStyleBar *)fontBar didClickBtn:(UIButton *)button{
    if (self.toolBarView.transform.ty>=0) {
        [self.webView showKeyboardContent];
    }
    switch (button.tag) {
        case 0:{
            //粗体
            [self.webView bold];
        }
            break;
        case 1:{//下划线
            [self.webView underline];
        }
            break;
        case 2:{//斜体
            [self.webView italic];
        }
            break;
        case 3:{//14号字体
            [self.webView setFontSize:@"2"];
        }
            break;
        case 4:{//16号字体
            [self.webView setFontSize:@"3"];
        }
            break;
        case 5:{//18号字体
            [self.webView setFontSize:@"4"];
        }
            break;
        case 6:{//左对齐
            [self.webView justifyLeft];
        }
            break;
        case 7:{//居中对齐
            [self.webView justifyCenter];
        }
            break;
        case 8:{//右对齐
            [self.webView justifyRight];
        }
            break;
        case 9:{//无序
            [self.webView unorderlist];
        }
            break;
        case 10:{
            //缩进
            button.selected = !button.selected;
            if (button.selected) {
                [self.webView indent];
            }else{
                [self.webView outdent];
            }
        }
            break;
        case 11:{
            
        }
            break;
        default:
            break;
    }
}
- (void)fontBarResetNormalFontSize{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.webView normalFontSize];
    });
}

#pragma mark -keyboard
- (void)keyBoardWillChangeFrame:(NSNotification*)notification{
    CGRect frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    if (frame.origin.y == SCREEN_HEIGHT) {
        [UIView animateWithDuration:duration animations:^{
            self.toolBarView.transform =  CGAffineTransformIdentity;
            self.toolBarView.keyboardButton.selected = NO;
        }];
    }else{
        [UIView animateWithDuration:duration animations:^{
            self.toolBarView.transform = CGAffineTransformMakeTranslation(0, -frame.size.height);
            self.toolBarView.keyboardButton.selected = YES;
            
        }];
    }
}

- (NSString *)getHtmlStr {
    return [self.webView contentHtmlText];
}

@end
