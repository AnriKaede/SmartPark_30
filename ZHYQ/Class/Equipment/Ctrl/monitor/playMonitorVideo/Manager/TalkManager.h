//
//  TalkManager.h
//  DemoDPSDK
//
//  Created by dahua on 15-4-2.
//  Copyright (c) 2015年 jiang_bin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "dhplayEx.h"
#import "DPSDK_Core_Define.h"
@interface TalkManager : NSObject
{
    void* fSdkAudioCallback;
    AudioUserParam_t* pAudioUserParam;
}
+ (TalkManager *) sharedInstance;

- (int)startTalk;

- (int)stopTalk;

- (void)onAudioCallFunction:(unsigned char*)pDataBuffer dataLen:(unsigned long)DataLength userData:(void*)pUserData;

-(void)getAudioSendCallback:(BOOL)bVto;
@end
