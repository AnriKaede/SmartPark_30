//
//  HotelViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/24.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "HotelViewController.h"
#import "NoDataView.h"
#import "WebLoadFailView.h"

@interface HotelViewController ()<UIWebViewDelegate, WebLoadFailDelegate>
{
    UIWebView *_webView;
    
    UIView *_headView;
    NoDataView *_noDataView;
    
    WebLoadFailView *webLoadFailView;
}

@end

@implementation HotelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadWeb) name:@"ResumeNetworkNotification" object:nil];
}

- (void)_initView {
    
    NSString *actUrl = [NSString stringWithFormat:@"http://220.168.59.11/hntfHotel/m/smartHotel/html/zhjd.jsp"];
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, -20, KScreenWidth, KScreenHeight + 20)];
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
    
    // 头部视图
    _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 64)];
    _headView.hidden = YES;
    _headView.backgroundColor = [UIColor colorWithHexString:@"#1B82D1"];
    [self.view addSubview:_headView];
    
    UIButton *headBtn = [[UIButton alloc] init];
    headBtn.frame = CGRectMake(20, 20, 40, 40);
    [headBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [headBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [headBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    [_headView addSubview:headBtn];
    
    // 加载失败图片
    _noDataView = [[NoDataView alloc] initWithFrame:CGRectMake(0, 64, KScreenWidth, KScreenHeight - 64)];
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
    self.navigationController.navigationBar.hidden = NO;
    [self.navigationController popViewControllerAnimated:YES];
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
    
    self.navigationController.navigationBar.hidden = NO;
    _noDataView.hidden = NO;
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue]  completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode != 200) {
            [self hideHud];
            webLoadFailView.hidden = NO;
            _noDataView.hidden = YES;
            _headView.hidden = NO;
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
    
    if([[NSString stringWithFormat:@"%@", request.URL] isEqualToString:@"http://192.168.206.23:8081/hntfEsb/pc/html/ludmain.jsp"]){
        _webView.canGoBack?[_webView goBack]:[self.navigationController popViewControllerAnimated:YES];
        self.navigationController.navigationBar.hidden = NO;
        
        return NO;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
