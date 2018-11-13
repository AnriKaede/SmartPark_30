//
//  ScanViewController.m
//  XTF_SmartPart_UserTerminal
//
//  Created by 焦平 on 2017/12/21.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "ScanViewController.h"
#import "YQScanView.h"
#import <AVFoundation/AVCaptureDevice.h>

#import "EquipmentInfoViewController.h"
#import "EquipmentInfoWebViewController.h"

@interface ScanViewController ()<YQScanViewDelegate>
{
    int line_tag;
    UIView *highlightView;
    NSString *scanMessage;
    BOOL isRequesting;
}

@property (nonatomic,weak) YQScanView *scanV;

@end

@implementation ScanViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self _initView];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    _scanV.delegate = nil;
    [_scanV removeFromSuperview];
    _scanV = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self _initNavItems];
    
    [self monitorNetwork];
}

#pragma mark 监听网络变化
- (void)monitorNetwork {
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                //NSLog(@"未识别的网络");
                
                // 无网络
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"NotNetworkNotification" object:nil];
                _scanV.noNetView.hidden = NO;
                _scanV.lab.hidden = NO;
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                //NSLog(@"不可达的网络(未连接)");
                _scanV.noNetView.hidden = NO;
                _scanV.lab.hidden = NO;
                // 无网络
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"NotNetworkNotification" object:nil];
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                //NSLog(@"2G,3G,4G...的网络");
                _scanV.noNetView.hidden = YES;
                _scanV.lab.hidden = YES;
                // 恢复网络
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"ResumeNetworkNotification" object:nil];
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                //NSLog(@"wifi的网络");
                _scanV.noNetView.hidden = YES;
                _scanV.lab.hidden = YES;
                // 恢复网络
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"ResumeNetworkNotification" object:nil];
                break;
            default:
                break;
        }
    }];
    
    [manager startMonitoring];
}

-(void)_initNavItems
{
    self.title = @"扫一扫";
    
    UIButton *leftBtn = [[UIButton alloc] init];
    leftBtn.frame = CGRectMake(0, 0, 40, 40);
    [leftBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [leftBtn setImage:[UIImage imageNamed:@"login_back"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(_leftBarBtnItemClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)_leftBarBtnItemClick {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)_initView
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
    {
        //无权限 弹框提示是否去开启相应权限
        
        NSString *msg = [NSString stringWithFormat:@"相机访问权限被禁用,是否去设置开启访问相机权限？"];
        UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        UIAlertAction *remove = [UIAlertAction actionWithTitle:@"去开启" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            
            [self performSelector:@selector(popView) withObject:nil afterDelay:0.5];
        }];
        
        [alertCon addAction:cancel];
        [alertCon addAction:remove];
        [self presentViewController:alertCon animated:YES completion:nil];
        
    }else{
        YQScanView *scanV = [[YQScanView alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, KScreenHeight)];
        scanV.delegate = self;
        [self.view addSubview:scanV];
        _scanV = scanV;
    }
}

-(void)popView{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 扫描完成协议 scanDataString二维码携带参数
-(void)getScanDataString:(NSString*)scanDataString{
    
    NSString *urlStr = [NSString stringWithFormat:@"%@", @"/h5/diningAdmin/html/deviceInfo.jsp"];
    if([scanDataString rangeOfString:urlStr].location == NSNotFound)
    {
        [self showHint:@"不可识别的二维码!"];
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    
    /*
    EquipmentInfoViewController *infoVC = [[UIStoryboard storyboardWithName:@"Home" bundle:nil] instantiateViewControllerWithIdentifier:@"EquipmentInfoViewController"];
    [self.navigationController pushViewController:infoVC animated:YES];
     */
    
    EquipmentInfoWebViewController *equWebVC = [[EquipmentInfoWebViewController alloc] init];
    equWebVC.urlStr = scanDataString;
    [self.navigationController pushViewController:equWebVC animated:YES];
}

-(NSMutableDictionary*)getURLParameters:(NSString *)str {
    NSRange range = [str rangeOfString:@"?"];
    if(range.location==NSNotFound) {
        return nil;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *parametersString = [str substringFromIndex:range.location+1];
    
    if([parametersString containsString:@"&"]) {
        
        NSArray *urlComponents = [parametersString componentsSeparatedByString:@"&"];
        
        for(NSString *keyValuePair in urlComponents) {
            
            //生成key/value
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
            NSString*value = [pairComponents.lastObject stringByRemovingPercentEncoding];
            
            //key不能为nil
            if(key==nil|| value ==nil) {
                continue;
            }
            id existValue = [params valueForKey:key];
            
            if(existValue !=nil) {
                //已存在的值，生成数组。
                if([existValue isKindOfClass:[NSArray class]]) {
                    //已存在的值生成数组
                    NSMutableArray*items = [NSMutableArray arrayWithArray:existValue];
                    [items addObject:value];
                    [params setValue:items forKey:key];
                }else{
                    //非数组
                    [params setValue:@[existValue,value]forKey:key];
                }
            }else{
                //设置值
                [params setValue:value forKey:key];
            }
        }
    }else{
        //单个参数生成key/value
        NSArray *pairComponents = [parametersString componentsSeparatedByString:@"="];
        if(pairComponents.count==1) {
            return nil;
        }
        //分隔值
        NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
        NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
        
        //key不能为nil
        if(key ==nil|| value ==nil) {
            return nil;
        }
        //设置值
        [params setValue:value forKey:key];
    }
    return params;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

