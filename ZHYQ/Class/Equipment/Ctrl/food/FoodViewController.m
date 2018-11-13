//
//  FoodViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2017/12/27.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "FoodViewController.h"
#import "NoDataView.h"
#import "WebLoadFailView.h"

@interface FoodViewController ()<UIWebViewDelegate, WebLoadFailDelegate>
{
    UIWebView *_webView;
    
    NoDataView *_noDataView;
    WebLoadFailView *webLoadFailView;
}

@end

@implementation FoodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadWeb) name:@"ResumeNetworkNotification" object:nil];
}

- (void)_initView {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    label.text = @"智慧餐饮";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:19];
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    
    self.navigationItem.titleView = label;
    
    // titleView点击事件
    UITapGestureRecognizer *homeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reloadWebView)];
    label.userInteractionEnabled = YES;
    [label addGestureRecognizer:homeTap];
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    NSString *actUrl = [NSString stringWithFormat:@"%@/txshop/shop/dingdan/initDingdaninfo.action?sellersId=064df94aa5124e64a1514ee17ef76a91&txuuid=61f6aff9e51e470ab44a7dcb6d1a8ca6",MealMain_Url];
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64)];
    _webView.scrollView.bounces = NO;
    NSURLRequest *reqest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:actUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5];
    [_webView loadRequest:reqest];
    _webView.delegate = self;
    [self.view addSubview:_webView];
    
    // 禁止左滑
    id traget = self.navigationController.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:traget action:nil];
    [self.view addGestureRecognizer:pan];
    
    // 加载失败图片
    _noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
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

- (void)_leftBarBtnItemClick {
    if([_webView canGoBack]){
        [_webView goBack];
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark UIWebView协议
- (void)webViewDidStartLoad:(UIWebView *)webView {
    webView.hidden = NO;
    [self showHudInView:self.view hint:nil];
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self hideHud];
    
    //    NSString *htmlTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    //    self.title = htmlTitle;
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

- (void)reloadWebView {
    [_webView removeFromSuperview];
    _webView.delegate = nil;
    _webView = nil;
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight - 64)];
    _webView.scrollView.bounces = NO;
    _webView.delegate = self;
    [self.view insertSubview:_webView belowSubview:_noDataView];
    
    NSString *actUrl = [NSString stringWithFormat:@"%@/txshop/shop/dingdan/initDingdaninfo.action?sellersId=064df94aa5124e64a1514ee17ef76a91&txuuid=61f6aff9e51e470ab44a7dcb6d1a8ca6",MealMain_Url];
    
    NSURLRequest *reqest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:actUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5];
    [_webView loadRequest:reqest];
}

#pragma mark 加载失败协议
- (void)reloadWeb {
    [self reloadWebView];
}

- (void)goHome {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ResumeNetworkNotification" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
