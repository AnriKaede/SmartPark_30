//
//  DistributorViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/5.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "SmartDistributorViewController.h"
#import "WebLoadFailView.h"
#import "NoDataView.h"
#import "DistributorFilterView.h"

#import <JavaScriptCore/JavaScriptCore.h>

@interface SmartDistributorViewController ()<UIWebViewDelegate, WebLoadFailDelegate>
{
    UIWebView *_webView;
    
    //    NoDataView *_noDataView;
    WebLoadFailView *webLoadFailView;
    
    DistributorFilterView *_distributorFilterView;
}
@end

@implementation SmartDistributorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadWeb) name:@"ResumeNetworkNotification" object:nil];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(22, kStatusBarHeight, 40, 40);
    [button setTitle:@"返回" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}
- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setStatusBarBackgroundColor:[UIColor colorWithHexString:@"#1B82D1"]];
//    [self setStatusBarBackgroundColor:[UIColor clearColor]];
}
//设置状态栏颜色
- (void)setStatusBarBackgroundColor:(UIColor *)color {
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self setStatusBarBackgroundColor:[UIColor clearColor]];
}

- (void)_initView {
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, -20, KScreenWidth, KScreenHeight + 20)];
    _webView.scrollView.bounces = NO;
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    // 加载url
    NSString *actUrl = [NSString stringWithFormat:@"http://192.168.206.19:9080/20171220admin/html/xldt.html"];
    NSURLRequest *reqest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:actUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5];
    [_webView loadRequest:reqest];
    
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
    
    webLoadFailView = [[WebLoadFailView alloc] initWithFrame:CGRectMake(0, kTopHeight, KScreenWidth, KScreenHeight - kTopHeight - kTabBarHeight)];
    webLoadFailView.hidden = YES;
    webLoadFailView.webLoadFailDelegate = self;
    [self.view addSubview:webLoadFailView];
    
    // 楼层图
    _distributorFilterView = [[DistributorFilterView alloc] initWithFrame:CGRectMake(0, kTopHeight, KScreenWidth, KScreenHeight - kTopHeight - kTabBarHeight)];
    [self.view addSubview:_distributorFilterView];
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
    // 退出 调用js方法
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
