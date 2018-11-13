//
//  LogRecordObj.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/2/8.
//  Copyright © 2018年 焦平. All rights reserved.
//

#import "LogRecordObj.h"

@implementation LogRecordObj

+ (void)recordLog:(NSDictionary *)paramDic {
    NSMutableDictionary *params = paramDic.mutableCopy;
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:KLoginUserName];
    [params setObject:userId forKey:@"userId"];
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    [params setObject:userName forKey:@"userName"];
    
    NSString *operateChannel = @"IOS";
    [params setObject:operateChannel forKey:@"operateChannel"];
    
    NSString *deviceName = [kUserDefaults objectForKey:KDeviceModel];
    [params setObject:deviceName forKey:@"deviceName"];
    
    NSString *deviceId = [kUserDefaults objectForKey:KDeviceUUID];
    [params setObject:deviceId forKey:@"deviceId"];
    
    NSString *paramStr = [Utils convertToJsonData:params];
    NSDictionary *jsonParam = @{@"param":paramStr};
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/operateLog/insertOperateLog", Main_Url];
//    NSString *urlStr = [NSString stringWithFormat:@"%@/operateLog/insertOperateLog", @"http://192.168.1.127:8080/hntfEsb"];
    [[NetworkClient sharedInstance] POST:urlStr dict:jsonParam progressFloat:nil succeed:^(id responseObject) {
        
        NSNumber *code = responseObject[@"code"];
        if (code != nil && ![code isKindOfClass:[NSNull class]] && code.integerValue == 100) {
            // 成功
            
        }else {
            NSLog(@"++++++++++++++++++记录日志失败");
        }
        
    } failure:^(NSError *error) {
        
    }];
    
    
}

@end
