//
//  LEDForworkDetailViewController.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/16.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "LEDForworkDetailViewController.h"
#import "WGCommon.h"
#define SCREEN_WIDTH  ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)

#define kEditorURL @"richText_editor"

@interface LEDForworkDetailViewController ()<UIWebViewDelegate, KWEditorBarDelegate,KWFontStyleBarDelegate>
{
    __weak IBOutlet UIView *_topBgView;
    __weak IBOutlet NSLayoutConstraint *_topBgViewHeight;
    __weak IBOutlet UITextField *_nameLabel;
    
    __weak IBOutlet UIWebView *_webView;
    __weak IBOutlet UIButton *_saveBt;
}
@property (nonatomic,strong) KWEditorBar *toolBarView;
@property (nonatomic,strong) KWFontStyleBar *fontBar;
@end

@implementation LEDForworkDetailViewController

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initWebView];
    [self _initNavItems];
    [self viewConfig];
    
}

- (void)_initWebView {
    _webView.delegate = self;
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    NSString * htmlPath = [[NSBundle mainBundle] pathForResource:kEditorURL                                                              ofType:@"html"];
    NSString * htmlCont = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    [_webView loadHTMLString:htmlCont baseURL:baseURL];
    _webView.scrollView.bounces=NO;
    _webView.hidesInputAccessoryView = YES;
}

-(void)_initNavItems {
    self.title = @"LED内容模板修改";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UITapGestureRecognizer *editTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditAction)];
    [self.view addGestureRecognizer:editTap];
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"#EFEFEF"];
    _saveBt.layer.cornerRadius = 4;
    _saveBt.layer.borderWidth = 1;
    _saveBt.layer.borderColor = [UIColor colorWithHexString:@"#1B82D1"].CGColor;
    
    [self.view addSubview:self.toolBarView];
}
- (void)endEditAction {
    [self.view endEditing:YES];
}

-(void)_leftBarBtnItemClick:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewConfig {
    [self.view addSubview:self.toolBarView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyBoardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    self.toolBarView.delegate = self;
    [self.toolBarView addObserver:self forKeyPath:@"transform" options:
     NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];
    
    // 是否是查看，默认是编辑
    if(!_isEdit){
        _topBgView.hidden = YES;
        _topBgViewHeight.constant = 0;
        
        [_saveBt setTitle:@"立即使用" forState:UIControlStateNormal];
        _webView.userInteractionEnabled = NO;
    }
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
        
        if ([_webView contentText].length <= 0) {
            [_webView showContentPlaceholder];
        }else{
            [_webView clearContentPlaceholder];
        }
        
        if ([[className componentsSeparatedByString:@","] containsObject:@"unorderedList"]) {
            [_webView clearContentPlaceholder];
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
    if ([_webView contentText].length <= 0)
    {
        [_webView showContentPlaceholder];
    }else{
        [_webView clearContentPlaceholder];
    }
}

#pragma mark -editorbarDelegate
- (void)editorBar:(KWEditorBar *)editorBar didClickIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:{
            //显示或隐藏键盘
            if (self.toolBarView.transform.ty < 0) {
                [_webView hiddenKeyboard];
            }else{
                [_webView showKeyboardContent];
            }
            
        }
            break;
        case 1:{
            //回退
            [_webView stringByEvaluatingJavaScriptFromString:@"document.execCommand('undo')"];
        }
            break;
        case 2:{
            [_webView stringByEvaluatingJavaScriptFromString:@"document.execCommand('redo')"];
        }
            break;
        case 3:{
            //显示更多区域
            editorBar.fontButton.selected = !editorBar.fontButton.selected;
            if (editorBar.fontButton.selected) {
                [self.view addSubview:self.fontBar];
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
        [_webView showKeyboardContent];
    }
    switch (button.tag) {
        case 0:{
            //粗体
            [_webView bold];
        }
            break;
        case 1:{//下划线
            [_webView underline];
        }
            break;
        case 2:{//斜体
            [_webView italic];
        }
            break;
        case 3:{//14号字体
            [_webView setFontSize:@"2"];
        }
            break;
        case 4:{//16号字体
            [_webView setFontSize:@"3"];
        }
            break;
        case 5:{//18号字体
            [_webView setFontSize:@"4"];
        }
            break;
        case 6:{//左对齐
            [_webView justifyLeft];
        }
            break;
        case 7:{//居中对齐
            [_webView justifyCenter];
        }
            break;
        case 8:{//右对齐
            [_webView justifyRight];
        }
            break;
        case 9:{//无序
            [_webView unorderlist];
        }
            break;
        case 10:{
            //缩进
            button.selected = !button.selected;
            if (button.selected) {
                [_webView indent];
            }else{
                [_webView outdent];
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
        [_webView normalFontSize];
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

- (IBAction)bottomBtAction:(id)sender {
    
}

@end
