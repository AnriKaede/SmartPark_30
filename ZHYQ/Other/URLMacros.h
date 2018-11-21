//
//  URLMacros.h
//  ZHYQ
//
//  Created by 焦平 on 2017/10/22.
//  Copyright © 2017年 焦平. All rights reserved.
//

#ifndef URLMacros_h
#define URLMacros_h

//内部版本号 每次发版递增
#define KVersionCode 1
/*
 
 将项目中所有的接口写在这里,方便统一管理,降低耦合
 
 这里通过宏定义来切换你当前的服务器类型,
 将你要切换的服务器类型宏后面置为真(即>0即可),其余为假(置为0)
 如下:现在的状态为测试服务器
 这样做切换方便,不用来回每个网络请求修改请求域名,降低出错事件
 
 */

#define DevelopSever    1
#define TestSever       0
#define ProductSever    0

#if DevelopSever

/**开发服务器*/

//公网
//#define eqMain_Url @"http://113.240.243.227/hntfEsb"

//#define Main_Url @"http://192.168.21.191:8081/hntfEsb"

//#define Main_Url @"http://220.168.59.11:8081/hntfEsb"

//#define Main_Url @"http://app.wisehn.com/hntfEsb"      // 域名
//#define Main_Url @"http://220.168.59.11:8081/hntfEsb" // alpha版本
#define Main_Url @"http://220.168.59.15:8081/hntfEsb"
//#define Main_Url @"http://192.168.21.45:8080/hntfEsb"   // 梁哥
//#define Main_Url @"http://192.168.206.23:8081/hntfEsb"
//#define Main_Url @"http://192.168.21.48:8080/hntfEsb" // 文可为
//#define Main_Url @"http://192.168.21.61:8080/hntfEsb"   // 岳昊
//#define Main_Url @"http://192.168.21.39:8080/hntfEsb" // 奉明保
//#define Main_Url @"http://192.168.21.33:8080/hntfEsb"   // 家新
//#define Main_Url @"http://192.168.21.141:8080/hntfEsb"    // 佳鑫
//#define Main_Url @"http://192.168.208.73:8080/hntfEsb"

#define MealMain_Url @"http://220.168.59.11:8083"   // 智慧餐饮、智慧幼儿园

//停车接口调试使用
//#define ParkMain_Url @"http://192.168.21.185:8080/park-service-1.0-SNAPSHOT/hntfEsb"
//#define ParkMain_Url @"http://www.hnzhangting.cn:9080/park-service/hntfEsb"
//#define ParkMain_Url @"http://www.hnzhangting.cn:8080/park-service/hntfEsb"
#define ParkMain_Url [NSString stringWithFormat:@"%@/park-service/hntfEsb", [[NSUserDefaults standardUserDefaults] objectForKey:KParkResquestIp]]
//#define ParkMain_Url @"http://192.168.21.186:8082/service/hntfEsb"

//#define ParkMain_Url @"http://192.168.1.134:8082/service/hntfEsb"
//#define ParkMain_Url @"http://192.168.21.58:8082/service/hntfEsb"

#elif TestSever

/**测试服务器*/
//#define Main_Url @"http://220.168.59.15:8081/hntfEsb"

#elif ProductSever

/**生产服务器*/
//#define Main_Url @"http://220.168.59.11:8081/hntfEsb"

#endif


#pragma mark - ——————— 详细接口地址 ————————

//测试接口



#endif /* URLMacros_h */
