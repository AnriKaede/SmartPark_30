//
//  IMUserQuery.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2019/3/16.
//  Copyright © 2019 焦平. All rights reserved.
//

#import "IMUserQuery.h"
#import "AppointChatUserModel.h"

@implementation IMUserQuery

static IMUserQuery *IMQueryInstance = nil;
static NSMutableArray *IMUserData;

+ (IMUserQuery *)shaerInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (IMQueryInstance == nil) {
            IMQueryInstance = [[self alloc] init];
            IMUserData = @[].mutableCopy;
        }
    });
    return IMQueryInstance;
}
+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (IMQueryInstance == nil) {
            IMQueryInstance = [super allocWithZone:zone];
        }
    });
    return IMQueryInstance;
}
- (instancetype)copyWithZone:(NSZone *)zone
{
    return IMQueryInstance;
}


- (void)loadServerUserData {
    NSString *urlStr = [NSString stringWithFormat:@"%@/pubSystemManage/querySystemUser", Main_Url];
    NSMutableDictionary *paramDic = @{}.mutableCopy;
    [paramDic setObject:[NSNumber numberWithInteger:1] forKey:@"offset"];
    [paramDic setObject:[NSNumber numberWithInteger:999] forKey:@"limit"];
    
    [[NetworkClient sharedInstance] GET:urlStr dict:paramDic progressFloat:nil succeed:^(id responseObject) {
        
        NSArray *rows = responseObject[@"rows"];
        if(rows != nil && ![rows isKindOfClass:[NSNull class]]){
            [IMUserData removeAllObjects];
            
            [rows enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                AppointChatUserModel *model = [[AppointChatUserModel alloc] initWithDataDic:obj];
                [IMUserData addObject:model];
            }];
        }
    } failure:^(NSError *error) {
    }];
}

- (NSString *)queryNickWithId:(NSString *)userId {
    __block NSString *nick = @"";
    [IMUserData enumerateObjectsUsingBlock:^(AppointChatUserModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        if([model.loginName isEqualToString:userId]){
            nick = model.userName;
        }
    }];
    return nick;
}

- (void)updateUserData:(NSMutableArray *)data {
    [IMUserData removeAllObjects];
    [IMUserData addObjectsFromArray:data];
}

- (NSMutableArray *)IMUserData {
    return IMUserData;
}

@end
