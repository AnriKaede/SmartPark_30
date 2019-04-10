//
//  MQTTTool.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/2/28.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "MQTTTool.h"

#define AddressOfMQTTServer @"192.168.206.21"
#define PortOfMQTTServerWithSSL 1883

#define MTQQUserName @"admin"
#define MTQQUserPassword @"hnslabc123cba"

@interface MQTTTool()<MQTTSessionDelegate>
@property (nonatomic,assign) BOOL isSSL;
@property (nonatomic,strong) NSMutableArray *subArray;
@end

@implementation MQTTTool
{
    BindUserComplete _bindUserComplete;
}

static MQTTTool *instance = nil;
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if(instance == nil){        
            instance = [[MQTTTool alloc] init];
        }
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil) {
            instance = [super allocWithZone:zone];
        }
    });
    return instance;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return instance;
}

#pragma mark 绑定
- (void)bindUser:(BindUserComplete)bindUserComplete {
    _bindUserComplete = bindUserComplete;

    [self setupMQTT];
}
- (void)setupMQTT {
    // keepAlive心跳间隔不得大于120s
    self.mySession = [[MQTTSession alloc]initWithClientId:@"" userName:MTQQUserName password:MTQQUserPassword keepAlive:60 cleanSession:YES will:NO willTopic:nil willMsg:nil willQoS:MQTTQosLevelAtLeastOnce willRetainFlag:NO protocolLevel:4 queue:dispatch_get_main_queue() securityPolicy:[self customSecurityPolicy] certificates:nil];
    
    self.isDiscontent = NO;
    
    self.mySession.delegate = self;
    
    //    [self.mySession connectToHost:AddressOfMQTTServer port:self.isSSL?PortOfMQTTServerWithSSL:PortOfMQTTServer usingSSL:isSSL];
    [self.mySession connectToHost:AddressOfMQTTServer port:self.isSSL?PortOfMQTTServerWithSSL:PortOfMQTTServerWithSSL usingSSL:_isSSL];
    
    [self.mySession addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
}
- (MQTTSSLSecurityPolicy *)customSecurityPolicy
{
    return nil;
    /*
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"ca" ofType:@"crt"];
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    MQTTSSLSecurityPolicy *securityPolicy = [MQTTSSLSecurityPolicy policyWithPinningMode:MQTTSSLPinningModeNone];
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesCertificateChain = YES;
    securityPolicy.validatesDomainName = NO;
    securityPolicy.pinnedCertificates = @[certData];
    return securityPolicy;
     */
}

#pragma mark ---- 状态
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    switch (self.mySession.status) {
        case MQTTSessionStatusClosed:
            NSLog(@"MQTT连接关闭");
            if (!self.isDiscontent) [self.mySession connect]; //这个是为了区分是主动断开还是被动断开。
            break;
        case MQTTSessionStatusConnected:
            NSLog(@"连接成功");
            _bindUserComplete(YES);
            //            [self subscribeTopicInArray];//这个是为了避免有部分订阅命令再连接完成前发送，导致订阅失败。
            break;
        case MQTTSessionStatusConnecting:
            NSLog(@"连接中");
            break;
        case MQTTSessionStatusError:
            NSLog(@"连接错误");
            _bindUserComplete(NO);
            break;
        case MQTTSessionStatusDisconnecting:
            NSLog(@"正在断开连接");
        default:
            break;
    }
    
}

#pragma mark - 订阅
- (void)subscribeTopic:(NSString *)topic withSubscribe:(SubscribeComplete)subscribeComplete {
    
    if (self.mySession.status != MQTTSessionStatusConnected  && ![self.subArray containsObject:topic]) {
        
        [self.subArray addObject:topic];
        return;
    }
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mySession subscribeToTopic:topic atLevel:MQTTQosLevelAtLeastOnce subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss) {
                if (error) {
                    subscribeComplete(NO);
                    NSLog(@"订阅失败 subscribeTopic failed ----- topic = %@ \n %@",topic,error.localizedDescription);
                    [weakSelf.subArray addObject:topic];
                    //                    [weakSelf subscribeTopicInArray];
                } else {
                    subscribeComplete(YES);
                    if ([weakSelf.subArray containsObject:topic]) {
                        [weakSelf.subArray removeObject:topic];
                    }
                    NSLog(@"subscribeTopic sucessfull 订阅成功！ topic = %@  \n %@",topic,gQoss);
                }
            }];
            
        });
    });
}

#pragma mark - 取消订阅
- (void)unsubscribeTopic:(NSString *)topic withUnsubscribe:(UnsubscribeComplete)unsubscribeComplete {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.mySession unsubscribeTopic:topic unsubscribeHandler:^(NSError *error) {
                if (error) {
                    unsubscribeComplete(NO);
                    NSLog(@"取消订阅失败unsubscribeTopic failed ----- topic = %@ \n %@",topic,error.localizedDescription);
                } else {
                    unsubscribeComplete(YES);
                    NSLog(@"unsubscribeTopic sucessfull 取消订阅成功！ topic = %@ ",topic);
                }
            }];
        });
    });
}

#pragma mark - 发布消息
- (void)sendDataToTopic:(NSString *)topic string:(NSString *)string {
    if(_mySession.status != MQTTSessionStatusConnected){
        if(_bindUserComplete != nil){
            [self bindUser:_bindUserComplete];
        }else {
            [self setupMQTT];
        }
    }
    [self.mySession publishData:[string dataUsingEncoding:NSUTF8StringEncoding] onTopic:topic];
}

// 数据接收回调
#pragma mark MQTTSessionDelegate
- (void)newMessage:(MQTTSession *)session data:(NSData *)data onTopic:(NSString *)topic qos:(MQTTQosLevel)qos retained:(BOOL)retained mid:(unsigned int)mid {
    NSLog(@"接受消息 thl -----  data = %@ \n -------- topic:%@ --------- \n",data,topic);
    
    //    NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"接收消息：%@", jsonData);
    
    if(_messageDelegate && [_messageDelegate respondsToSelector:@selector(messageData:onTopic:)]) {
        [_messageDelegate messageData:data onTopic:topic];
    }
}

- (void)handleEvent:(MQTTSession *)session event:(MQTTSessionEvent)eventCode error:(NSError *)error
{
    if (error != nil) {
        NSLog(@"error-%@",error);
    }
}

// 主动断开
- (void)disconnect {
    
    [self.mySession disconnect];
    
    [self.mySession removeObserver:self forKeyPath:@"status"];
    
    self.isDiscontent = YES;
}

@end
