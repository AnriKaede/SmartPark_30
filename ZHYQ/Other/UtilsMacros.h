//
//  UtilsMacros.h
//  ZHYQ
//
//  Created by 焦平 on 2017/10/22.
//  Copyright © 2017年 焦平. All rights reserved.
//

#ifndef UtilsMacros_h
#define UtilsMacros_h

//获取系统对象
#define kApplication        [UIApplication sharedApplication]
#define kAppWindow          [UIApplication sharedApplication].delegate.window
#define kAppDelegate        [AppDelegate shareAppDelegate]
#define kRootViewController [UIApplication sharedApplication].delegate.window.rootViewController
#define kUserDefaults       [NSUserDefaults standardUserDefaults]
#define kNotificationCenter [NSNotificationCenter defaultCenter]

#define kStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define kNavBarHeight 44.0
#define kTabBarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height>20?83:49)
#define kTopHeight (kStatusBarHeight + kNavBarHeight)

//获取屏幕宽高
#define KScreenWidth [[UIScreen mainScreen] bounds].size.width
#define KScreenHeight [[UIScreen mainScreen] bounds].size.height
#define kScreen_Bounds [UIScreen mainScreen].bounds

//判断是否是iPhone X
#define kDevice_Is_iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

// 判断是否是iPhone5
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)]\
? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size)\
|| CGSizeEqualToSize(CGSizeMake(1136, 640), [[UIScreen mainScreen] currentMode].size) : NO)

#define wScale KScreenWidth/375.0
#define hScale KScreenHeight/667.0

//根据ip6的屏幕来拉伸
#define kRealValue(with) ((with)*(KScreenWidth/375.0f))

//#define KTabBarHeight 60

//强弱引用
/** 弱引用 */
#define WEAKSELF __weak typeof(self) weakSelf = self;

//View 圆角和加边框
#define ViewBorderRadius(View, Radius, Width, Color)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES];\
[View.layer setBorderWidth:(Width)];\
[View.layer setBorderColor:[Color CGColor]]

// View 圆角
#define ViewRadius(View, Radius)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES]

//property 属性快速声明 别用宏定义了，使用代码块+快捷键实现吧

///IOS 版本判断
#define IOSAVAILABLEVERSION(version) ([[UIDevice currentDevice] availableVersion:version] < 0)
// 当前系统版本
#define CurrentSystemVersion [[UIDevice currentDevice].systemVersion doubleValue]
//当前语言
#define CurrentLanguage (［NSLocale preferredLanguages] objectAtIndex:0])

//-------------------打印日志-------------------------
//DEBUG  模式下打印日志,当前行
#ifdef DEBUG
#define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define DLog(...)
#endif

//拼接字符串
#define NSStringFormat(format,...) [NSString stringWithFormat:format,##__VA_ARGS__]

//颜色
#define KClearColor [UIColor clearColor]
#define KWhiteColor [UIColor whiteColor]
#define KBlackColor [UIColor blackColor]
#define KGrayColor [UIColor grayColor]
#define KGray2Color [UIColor lightGrayColor]
#define KBlueColor [UIColor blueColor]
#define KRedColor [UIColor redColor]
#define kRandomColor    KRGBColor(arc4random_uniform(256)/255.0,arc4random_uniform(256)/255.0,arc4random_uniform(256)/255.0)        //随机色生成

//字体
#define BOLDSYSTEMFONT(FONTSIZE)[UIFont boldSystemFontOfSize:FONTSIZE]
#define SYSTEMFONT(FONTSIZE)    [UIFont systemFontOfSize:FONTSIZE]
#define FONT(NAME, FONTSIZE)    [UIFont fontWithName:(NAME) size:(FONTSIZE)]


//定义UIImage对象
#define ImageWithFile(_pointer) [UIImage imageWithContentsOfFile:([[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@@%dx", _pointer, (int)[UIScreen mainScreen].nativeScale] ofType:@"png"])]
#define IMAGE_NAMED(name) [UIImage imageNamed:name]

//数据验证
#define StrValid(f) (f!=nil && [f isKindOfClass:[NSString class]] && ![f isEqualToString:@""])
#define SafeStr(f) (StrValid(f) ? f:@"")
#define HasString(str,key) ([str rangeOfString:key].location!=NSNotFound)

#define ValidStr(f) StrValid(f)
#define ValidDict(f) (f!=nil && [f isKindOfClass:[NSDictionary class]])
#define ValidArray(f) (f!=nil && [f isKindOfClass:[NSArray class]] && [f count]>0)
#define ValidNum(f) (f!=nil && [f isKindOfClass:[NSNumber class]])
#define ValidClass(f,cls) (f!=nil && [f isKindOfClass:[cls class]])
#define ValidData(f) (f!=nil && [f isKindOfClass:[NSData class]])

//获取一段时间间隔
#define kStartTime CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
#define kEndTime  NSLog(@"Time: %f", CFAbsoluteTimeGetCurrent() - start)
//打印当前方法名
#define ITTDPRINTMETHODNAME() ITTDPRINT(@"%s", __PRETTY_FUNCTION__)


//发送通知
#define KPostNotification(name,obj) [[NSNotificationCenter defaultCenter] postNotificationName:name object:obj];

//单例化一个类
#define SINGLETON_FOR_HEADER(className) \
\
+ (className *)shared##className;

#define SINGLETON_FOR_CLASS(className) \
\
+ (className *)shared##className { \
static className *shared##className = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
shared##className = [[self alloc] init]; \
}); \
return shared##className; \
}

//用户登录状态
#define KLoginState @"LoginState" // 用户登录状态
#define KLoginUserName @"loginUserName" // 当前登录用户名
#define KLoginPasword @"loginPasword" // 当前登录密码

#define KDeviceModel @"deviceModel" // 手机型号
#define KDeviceUUID @"deviceUUID" // 手机唯一标示

#define KRemeberUser @"remeberUser"    // 记住用户名
#define KRemeberPassword @"remeberPassword"    // 记住密码

/*------------------------------*/
#define KNewLoginFlag @"NewLoginFlag"    // 17新版本强制重新登录，获取新登录信息 BOOL类型

#define KAdminCompanyId @"adminCompanyId"    // 公司ID
#define KRoleIdList @"roleIdList"    // 角色集合，可多个角色，每个角色对应不同权限
#define KAdminUserId @"adminUserId" // 账号userID
#define KAdminLoginToken @"adminLoginToken" // 登录token

#define KIsRepairman @"isRepairman" // 是否维修人员 BOOL类型

/*----------------------------------*/

#define KMonitorInfo @"monitorInfo" // 大华视频sdk登录信息

#define KParkId @"8a04a41f56bc33a20156bc3726df0004"
#define KAreaId @"8a04a41f56c0c3f90157277802150065"

#define KParkResquestIp @"parkResquestIp"

#define KRequestFailMsg @"网络不给力，请稍后重试~"

// 地图默认经纬度（天园）
#define KMapLocationCoord @"mapLocationCoord"

// 版本更新提醒信息
#define KAlertTime @"alertTime"         // 提醒时间
#define KDifferVersion @"differVersion" // 相差版本数
#define KAlertNum @"alertNum"           // 提醒次数

#define KNeedRemain @"needremain"       // 是否需要红点提示

#define KFirstLauch @"firstLauch"       // 是否是第一次启动，显示引导页

// 人脸图片沙盒地址
#define FaceHistoryPath [NSHomeDirectory() stringByAppendingString:@"/Documents/FaceHistoryData/"]

#define AESKey @"660c345cf08a4829"

#define AirMinTemp 18
#define AirMaxTemp 30

#endif /* UtilsMacros_h */
