//
//  NetworkClient.m
//  ZHYQ
//
//  Created by 焦平 on 2017/11/1.
//  Copyright © 2017年 焦平. All rights reserved.
//

#import "NetworkClient.h"
#import "Utils.h"

@implementation NetworkClient

/**
 *创建网络请求类的单例
 */
static NetworkClient *netWorkClient = nil;

+ (NetworkClient *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (netWorkClient == nil) {
            netWorkClient = [[self alloc] init];
        }
    });
    return netWorkClient;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (netWorkClient == nil) {
            netWorkClient = [super allocWithZone:zone];
        }
    });
    return netWorkClient;
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    return netWorkClient;
}
/**
 *GET请求
 *
 *@param URLString 网络请求地址
 *@param dict参数(可以是字典或者nil)
 *@param succeed 成功后执行success block
 *@param failure 失败后执行failure block
 */
- (void)GET:(NSString *)URLString dict:(id)dict progressFloat:(ProgressFloat)progressFloat succeed:(Succeed)succeed failure:(Failure)failure
{
    //创建网络请求管理对象
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
#warning 请求头添加统一参数
    NSMutableDictionary *reqParams = [self getHeaderParam];
    
    // https证书
    manager.securityPolicy = [self customSecurityPolicy];
    
    NSString *jsonStr = [Utils convertToJsonData:reqParams];
    
    [manager.requestSerializer setValue:jsonStr forHTTPHeaderField:@"wisehn-param"];
    
    manager.requestSerializer.timeoutInterval = 10;
    //设置请求接口回来的时候支持什么类型的数据
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/xml",@"text/xml",@"text/html",@"text/plain",@"text/json",@"application/json",nil];
    
    NSString *utfString = [URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //发送网络请求(请求方式为GET)
    [manager GET:utfString parameters:dict progress:^(NSProgress * _Nonnull downloadProgress) {
        //下载进度
        if(progressFloat != nil){
            float downloadPro = 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
            progressFloat(downloadPro);
        }
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        
        succeed(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        failure(error);
        
    }];
}
/**
 *POST请求 form-data 方式
 *
 *@param URLString 网络请求地址
 *@param dict参数(可以是字典或者nil)
 *@param succeed 成功后执行success block
 *@param failure 失败后执行failure block
 */
- (void)POST:(NSString *)URLString dict:(id)dict progressFloat:(ProgressFloat)progressFloat succeed:(Succeed)succeed failure:(Failure)failure
{
    //创建网络请求管理对象
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
#warning 请求头添加统一参数
    NSMutableDictionary *reqParams = [self getHeaderParam];
    
    // https证书
    manager.securityPolicy = [self customSecurityPolicy];
    
    NSString *jsonStr = [Utils convertToJsonData:reqParams];
    
    [manager.requestSerializer setValue:jsonStr forHTTPHeaderField:@"wisehn-param"];
    
    manager.requestSerializer.timeoutInterval = 30;
    
    //设置请求接口回来的时候支持什么类型的数据
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/xml",@"text/html",@"text/plain",@"text/json",@"application/xml",nil];
    
    NSString *utfString = [URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //发送网络请求(请求方式为POST)
    [manager POST:utfString parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
        //下载进度
        if(progressFloat != nil){
            float downloadPro = 1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount;
            progressFloat(downloadPro);
        }
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        //        if([responseObject containsObject:@"success"] || [responseObject[@"error"] isKindOfClass:[NSNull class]]){
        
        succeed(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        failure(error);
        
    }];
}

/**
 *POST请求 raw 方式
 *
 *@param URLString 网络请求地址
 *@param dict参数(可以是字典或者nil)
 *@param succeed 成功后执行success block
 *@param failure 失败后执行failure block
 */
- (void)POSTRaw:(NSString *)URLString dict:(id)dict progressFloat:(ProgressFloat)progressFloat succeed:(Succeed)succeed failure:(Failure)failure
{
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    // https证书
    manager.securityPolicy = [self customSecurityPolicy];
    
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:URLString parameters:nil error:nil];

    NSData *postBody = [NSJSONSerialization dataWithJSONObject:dict  options:NSJSONWritingPrettyPrinted error:nil];
    
    unsigned long long postLength = postBody.length;
    NSString *contentLength = [NSString stringWithFormat:@"%llu", postLength];
    [request addValue:contentLength forHTTPHeaderField:@"Content-Length"];
    
    request.timeoutInterval = 10;
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/x-www-form-urlencoded charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postBody];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error) {
            succeed(responseObject);
        } else {
            failure(error);
        }
    }];
    
    [dataTask resume];
}

/**
 *下载文件
 *
 *@param URLString 网络请求地址
 *@param progressFloat 当前的下载进度
 *@param downLoadDic 保存下载完成的状态和路径
 */
-(void)DOWNLOAD:(NSString *)URLString progressFloat:(ProgressFloat)progressFloat downLoadDic:(Succeed)downLoadDic
{
    //创建管理者对象
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 10;
    
    NSString *utfString = [URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //创建请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:utfString]];
    //下载任务
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        //下载进度
        if(progressFloat != nil){
            float downloadPro = 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
            progressFloat(downloadPro);
        }
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        //下载到哪个文件夹
        NSString *cachePath=NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
        NSString *fileName=[cachePath stringByAppendingPathComponent:response.suggestedFilename];
        return [NSURL fileURLWithPath:fileName];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        //保存数据到字典
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        if (error)
            [dictionary setObject:error forKey:@"error"];
        //将url转成字符串去掉开头的file:再保存到字典
        if ([filePath absoluteString])
        {
            NSString *filePathStr = [filePath absoluteString];
            if ([filePathStr hasPrefix:@"file:"]) {
                filePathStr = [[filePath absoluteString] substringFromIndex:5];
            }
            [dictionary setObject:filePathStr forKey:@"filePath"];
        }
        //下载完成调用的方法
        downLoadDic(dictionary);
        
    }];//开始启动任务
    [task resume];
}
/**
 *上传图片
 *
 *@param URLString 网络请求地址
 *@param dict 参数(可以是字典或者nil)
 *@param imageArray保存图片的数组
 *@param progressFloat 当前的上传进度
 *@param succeed上传成功
 *@param failure上传失败
 */
-(void)UPLOAD:(NSString *)URLString dict:(id)dict imageArray:(id)imageArray progressFloat:(ProgressFloat)progressFloat succeed:(Succeed)succeed failure:(Failure)failure
{
    //创建管理者对象
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 10;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    //设置请求接口回来的时候支持什么类型的数据
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/xml",@"text/html",@"text/plain",@"text/json",@"application/xml",nil];
    
    NSString *utfString = [URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [manager POST:utfString parameters:dict constructingBodyWithBlock:^(id _Nonnull formData) {
        
        //保证当前上传图片名字的唯一性，获取当前时间戳
        NSDate *senddate=[NSDate date];
        NSDateFormatter*dateformatter=[[NSDateFormatter alloc] init];
        [dateformatter setDateFormat:@"YYMMddHHmmss"];
        NSString *locationString=[dateformatter stringFromDate:senddate];
        for (int i = 0; i < [(NSMutableArray *)imageArray count]; i ++) {
            //获取每一张图片转成data
            UIImage *image = imageArray[i];
            NSData *data = UIImageJPEGRepresentation(image, 0.7);
            //时间戳拼接当前的i得到图片的名字
            NSString *name = [locationString stringByAppendingString:[NSString stringWithFormat:@"%d",i]];
            //这个就是上传的参数
            [formData appendPartWithFileData:data name:name fileName:[NSString stringWithFormat:@"%@.jpg",name] mimeType:@"image/jpeg"];
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //打印下上传进度
        if(progressFloat != nil){
            float downloadPro = 1.0 * uploadProgress.completedUnitCount / uploadProgress.totalUnitCount;
            progressFloat(downloadPro);
        }
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        
        succeed(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        failure(error);
        
    }];
}

#pragma mark 返回请求头需要参数
- (NSMutableDictionary *)getHeaderParam {
    NSMutableDictionary *reqParams =@{}.mutableCopy;
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:KAdminUserId];
    if(userId != nil && ![userId isKindOfClass:[NSNull class]]){
        [reqParams setObject:userId forKey:@"userId"];
    }
    
    [reqParams setObject:@"admin" forKey:@"userType"];
    
    [reqParams setObject:@"IOS" forKey:@"agent"];
    
    NSString *companyId = [[NSUserDefaults standardUserDefaults] objectForKey:KAdminCompanyId];
    if(companyId != nil && ![companyId isKindOfClass:[NSNull class]]){
        [reqParams setObject:companyId forKey:@"companyId"];
    }
    
//    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:KLoginUserName];
    NSString *userName = [kUserDefaults objectForKey:@"userName"];
    if(userName != nil && ![userName isKindOfClass:[NSNull class]]){
        userName = [userName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [reqParams setObject:userName forKey:@"userName"];
    }
    
    NSString *roleList = [[NSUserDefaults standardUserDefaults] objectForKey:KRoleIdList];
    if(roleList != nil && ![roleList isKindOfClass:[NSNull class]]){
        [reqParams setObject:roleList forKey:@"roleList"];
    }
    
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:KAdminLoginToken];
    if(token != nil && ![token isKindOfClass:[NSNull class]]){
        [reqParams setObject:token forKey:@"token"];
    }
    
    return reqParams;
}

#pragma mark https
- (AFSecurityPolicy *)customSecurityPolicy{
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"220.168.59.13" ofType:@"cer"];
    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
    
    if (cerData == nil) {
        return nil;
    }
    NSSet *setData = [NSSet setWithObject:cerData];
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesDomainName = NO;
    [securityPolicy setPinnedCertificates:setData];
    return securityPolicy;
}

@end

