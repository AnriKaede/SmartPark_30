//
//  LightLockWebViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/5/25.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "LightLockWebViewController.h"
#import "NoDataView.h"
#import "WebLoadFailView.h"

#import <JavaScriptCore/JavaScriptCore.h>

@interface LightLockWebViewController ()<UIWebViewDelegate, WebLoadFailDelegate>
{
    UIButton *_backBt;
    UIWebView *_webView;
    
//    NoDataView *_noDataView;
    WebLoadFailView *webLoadFailView;
}

@end

@implementation LightLockWebViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self setStatusBarBackgroundColor:[UIColor colorWithHexString:@"#48a0f7"]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self setStatusBarBackgroundColor:[UIColor clearColor]];
}

//设置状态栏颜色
- (void)setStatusBarBackgroundColor:(UIColor *)color {
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadWeb) name:@"ResumeNetworkNotification" object:nil];
    
    [self _loadData];
}

- (void)_initView {
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
    _webView.scrollView.bounces = NO;
    _webView.hidden = YES;
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    _backBt = [UIButton buttonWithType:UIButtonTypeCustom];
//    _backBt.hidden = YES;
    _backBt.frame = CGRectMake(10, 30, 20, 20);
    [_backBt setBackgroundImage:[UIImage imageNamed:@"nav_back"] forState:UIControlStateNormal];
    [_backBt addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view insertSubview:_backBt aboveSubview:_webView];
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    // 禁止左滑
    id traget = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:traget action:nil];
    [self.view addGestureRecognizer:pan];
    
    /*
    // 无网络加载失败图片
    _noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64)];
    _noDataView.hidden = YES;
    _noDataView.backgroundColor = [UIColor whiteColor];
    _noDataView.label.text = @"";
    _noDataView.imgView.image = [UIImage imageNamed:@"customvoice_networkerror"];
    _noDataView.label.text = @"对不起,网络连接失败";
    _noDataView.label.textColor = [UIColor colorWithHexString:@"#1B82D1"];
    [self.view addSubview:_noDataView];
     */
    
    webLoadFailView = [[WebLoadFailView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64)];
    webLoadFailView.hidden = YES;
    webLoadFailView.webLoadFailDelegate = self;
    [self.view addSubview:webLoadFailView];
}

-(void)_leftBarBtnItemClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 查询webview token
- (void)_loadData {
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/public/getWlwToken", Main_Url];
    [self showHudInView:self.view hint:@""];
    [[NetworkClient sharedInstance] GET:urlStr dict:nil progressFloat:nil succeed:^(id responseObject) {
        [self hideHud];
        NSString *code = responseObject[@"code"];
        if(code != nil && ![code isKindOfClass:[NSNull class]] && [code isEqualToString:@"1"]){
            NSString *responseData = responseObject[@"responseData"];
            
            NSData *jsonData = [responseData dataUsingEncoding:NSUTF8StringEncoding];
            
            NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
            
            NSString *resultValue = jsonDic[@"resultValue"];
            
            if(resultValue != nil && ![resultValue isKindOfClass:[NSNull class]]){
                // 加载h5
                [self webViewLoadUrl:resultValue];
            }
            _backBt.hidden = YES;
        }else {
            webLoadFailView.hidden = NO;
            NSString *message = responseObject[@"message"];
            if(message != nil && ![message isKindOfClass:[NSNull class]]){
                [self showHint:message];
            }
            _backBt.hidden = NO;
        }
    } failure:^(NSError *error) {
        [self hideHud];
        webLoadFailView.hidden = NO;
        _backBt.hidden = NO;
    }];
    
}

- (void)webViewLoadUrl:(NSString *)urlStr {
    _webView.hidden = NO;
    NSString *actUrl = [NSString stringWithFormat:@"http://202.103.100.251:8081/IOT-H5-WEB/jsp/user-toll-list.view?token=%@", urlStr];
    NSURLRequest *reqest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:actUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5];
    [_webView loadRequest:reqest];
}

#pragma mark UIWebView协议
- (void)webViewDidStartLoad:(UIWebView *)webView {
//    [self showHudInView:self.view hint:nil];
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    [self hideHud];
//    _noDataView.hidden = YES;
    webLoadFailView.hidden = YES;
    
//    self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
     JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
     // 报修完成
     context[@"close"] = ^() {
     dispatch_async(dispatch_get_main_queue(), ^{
         
         [self.navigationController popToRootViewControllerAnimated:YES];
         
         });
     };
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
//    [self hideHud];
    [self showHint:@"加载失败"];
    
//    _noDataView.hidden = NO;
    webLoadFailView.hidden = NO;
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]  completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode != 200) {
            [self hideHud];
            webLoadFailView.hidden = NO;
//            _noDataView.hidden = YES;
        }else {
            webLoadFailView.hidden = YES;
//            _noDataView.hidden = YES;
        }
    }];
    
    NSString *str = @"about:blank";
    if([[NSString stringWithFormat:@"%@", request.URL] isEqualToString:str]){
        if([webView canGoBack]){
            [webView goBack];
        }
    }
    
    return YES;
}

#pragma mark 加载失败协议
- (void)reloadWeb {
    [_webView reload];
}

- (void)goHome {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ResumeNetworkNotification" object:nil];
}

@end
