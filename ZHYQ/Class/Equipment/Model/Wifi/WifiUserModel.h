//
//  WifiUserModel.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/6.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface WifiUserModel : BaseModel

/*
{
    "access_agent" = "-";
    ap = "3层306_A8_61";
    "auth_type" = "WPA-PSK/WPA2-PSK(个人)";
    channel = "2.4G";
    client = "Windows PC";
    clientphy = "802.11bgn";
    computer = "USER-20180716HT";
    consultRate = 72000;
    "disaster_type" = "非灾备用户";
    "discharge_flag" = 0;
    errorCodeRate = 0;
    group = "/PSK认证组/";
    "home_agent" = "-";
    ip = "192.168.208.9";
    "is_wireless" = 1;
    mac = "48-5A-B6-DF-7B-63";
    "nc_maker" = "Hon Hai Precision Ind. Co.,Ltd.";
    onlineTime = "0天6小时45分46秒";
    privateIP = "否";
    recv = 0;
    retrans = 0;
    role = ZGTF;
    send = 0;
    signal = 13;
    signalStrength = "-55";
    "term_type_id" = 36;
    "user_identity" = "";
    username = "48-5A-B6-DF-7B-63";
    vlan = 218;
    wlan = ZGTF;
}
 */

@property (nonatomic,copy) NSString *access_agent;
@property (nonatomic,copy) NSString *ap;
@property (nonatomic,copy) NSString *auth_type;
@property (nonatomic,copy) NSString *channel;
@property (nonatomic,copy) NSString *client;
@property (nonatomic,copy) NSString *clientphy;
@property (nonatomic,copy) NSString *computer;
@property (nonatomic,strong) NSNumber *consultRate;
@property (nonatomic,copy) NSString *disaster_type;
@property (nonatomic,strong) NSNumber *discharge_flag;
@property (nonatomic,strong) NSNumber *errorCodeRate;
@property (nonatomic,copy) NSString *group;
@property (nonatomic,copy) NSString *home_agent;
@property (nonatomic,copy) NSString *ip;
@property (nonatomic,copy) NSString *is_wireless;
@property (nonatomic,copy) NSString *mac;
@property (nonatomic,copy) NSString *nc_maker;
@property (nonatomic,copy) NSString *onlineTime;
@property (nonatomic,copy) NSString *privateIP;
@property (nonatomic,strong) NSNumber *recv;
@property (nonatomic,strong) NSNumber *retrans;
@property (nonatomic,copy) NSString *role;
@property (nonatomic,strong) NSNumber *send;
@property (nonatomic,strong) NSNumber *signal;
@property (nonatomic,copy) NSString *signalStrength;
@property (nonatomic,strong) NSNumber *term_type_id;
@property (nonatomic,copy) NSString *user_identity;
@property (nonatomic,copy) NSString *username;
@property (nonatomic,strong) NSNumber *vlan;
@property (nonatomic,copy) NSString *wlan;

@end

NS_ASSUME_NONNULL_END
