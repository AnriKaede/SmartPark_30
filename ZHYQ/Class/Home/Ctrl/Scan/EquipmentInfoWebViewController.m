//
//  EquipmentInfoWebViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/5/16.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "EquipmentInfoWebViewController.h"
#import "NoDataView.h"
#import "WebLoadFailView.h"

#import <JavaScriptCore/JavaScriptCore.h>

@interface EquipmentInfoWebViewController ()<UIWebViewDelegate, WebLoadFailDelegate>
{
    UIWebView *_webView;
    
    NoDataView *_noDataView;
    WebLoadFailView *webLoadFailView;
}

@end

@implementation EquipmentInfoWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadWeb) name:@"ResumeNetworkNotification" object:nil];
}

- (void)_initView {
    
    NSString *actUrl = [NSString stringWithFormat:@"%@", _urlStr];
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64 - 60)];
    _webView.scrollView.bounces = NO;
    NSURLRequest *reqest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:actUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5];
    [_webView loadRequest:reqest];
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
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
    
    // 无网络加载失败图片
    _noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64)];
    _noDataView.hidden = YES;
    _noDataView.backgroundColor = [UIColor whiteColor];
    _noDataView.label.text = @"";
    _noDataView.imgView.image = [UIImage imageNamed:@"customvoice_networkerror"];
    _noDataView.label.text = @"对不起,网络连接失败";
    _noDataView.label.textColor = [UIColor colorWithHexString:@"#1B82D1"];
    [self.view addSubview:_noDataView];
    
    webLoadFailView = [[WebLoadFailView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64)];
    webLoadFailView.hidden = YES;
    webLoadFailView.webLoadFailDelegate = self;
    [self.view addSubview:webLoadFailView];
}

-(void)_leftBarBtnItemClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UIWebView协议
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self showHudInView:self.view hint:nil];
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self hideHud];
    _noDataView.hidden = YES;
    
    self.title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    /*
    JSContext *context=[webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    // 报修完成
    context[@"fboxClose"] = ^() {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
    };
     */
    
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self hideHud];
    [self showHint:@"加载失败"];
    
    _noDataView.hidden = NO;
    webLoadFailView.hidden = YES;
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]  completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode != 200) {
            [self hideHud];
            webLoadFailView.hidden = NO;
            _noDataView.hidden = YES;
        }else {
            webLoadFailView.hidden = YES;
            _noDataView.hidden = YES;
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
