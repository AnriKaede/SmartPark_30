//
//  MQTTTool.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/2/28.
//  Copyright © 2019 焦平. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MQTTClient.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MQTTMessageDelegate <NSObject>

- (void)messageData:(NSData *)data onTopic:(NSString *)topic;

@end

typedef void (^BindUserComplete) (BOOL isSuccess);
typedef void (^SubscribeComplete) (BOOL isSuccess);
typedef void (^UnsubscribeComplete) (BOOL isSuccess);
typedef void (^AchieveMessage) (NSData *data, NSString *topic);

@interface MQTTTool : NSObject

+ (instancetype)shareInstance;

@property (nonatomic,strong) MQTTSession *mySession;
@property (nonatomic,assign) BOOL isDiscontent;
@property (nonatomic,assign) id<MQTTMessageDelegate> messageDelegate;

// 绑定用户
- (void)bindUser:(BindUserComplete)bindUserComplete;

// 订阅
- (void)subscribeTopic:(NSString *)topic withSubscribe:(SubscribeComplete)subscribeComplete;

// 取消订阅
- (void)unsubscribeTopic:(NSString *)topic withUnsubscribe:(UnsubscribeComplete)unsubscribeComplete;

// 发布消息
- (void)sendDataToTopic:(NSString *)topic string:(NSString *)string;

// 断开连接
- (void)disconnect;

@end

NS_ASSUME_NONNULL_END
