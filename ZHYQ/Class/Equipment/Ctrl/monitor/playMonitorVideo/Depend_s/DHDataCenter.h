//
//  DHDataCenter.h
//  DahuaVision
//
//  Created by nobuts on 13-6-4.
//  Copyright (c) 2013年 Dahuatech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PubDefine.h"
#import "DPSDK_Core.h"
#import "DPSDK_Core_Define.h"
#import "DPSDK_Core_Error.h"
#import "DHPubfun.h"
//#import "DHHudPrecess.h"
#import "DeviceTree.h"

@interface DHDataCenter : NSObject
{
@public
    int32_t  nDPHandle_;        /**< DPSDK句柄 */
}

@property (nonatomic,assign) int  nTimeout;
@property (nonatomic,assign) int  serverPort;
@property (nonatomic,assign) BOOL bAutoLogin;
@property (nonatomic,assign) BOOL bLogin;
@property (nonatomic,strong) NSString   *serverIP;
@property (nonatomic,strong) NSString   *userName;
@property (nonatomic,strong) NSString   *passCode;
@property (nonatomic,strong) NSString   *channelID;
@property (nonatomic,strong) DeviceTreeNode  *CamerasGroups;


//可视对讲属性
@property (nonatomic,strong) NSMutableArray  *arrVTNodes;
@property (nonatomic,strong) NSString  *incomingTalkChnlID;


+ (DHDataCenter *) sharedInstance;
+ (void)refreshOrganTree:(DeviceTreeNode *)pNode withChannelRight:(UNLLONG)right;
+ (void)refreshOrganTreeHiddenStatus:(DeviceTreeNode *)pNode ignoreCollectionNode:(BOOL)ignoreCollection;
- (void) loadAccount;
- (void) saveAccount;

@end
