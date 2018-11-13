//
//  PlayerManager.h
//  DemoDPSDK
//
//  Created by dahua on 15-4-3.
//  Copyright (c) 2015年 jiang_bin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "dhplayEx.h"

@interface PlayerManager : NSObject
@property (assign,nonatomic) BOOL  isPlaying;
+ (PlayerManager *) sharedInstance;

- (long)getFreePort;

- (BOOL)startRealPlay:(long)iPort window:(void *)hWnd;

- (BOOL)startRecordPlay:(long)iPort window:(void *)hWnd;

- (BOOL)startTalk:(long)iPort bVtoTalk:(BOOL)bVto;

- (BOOL)stopRealPlay:(long)iPort;

- (BOOL)stopRecordPlay:(long)iPort;

- (BOOL)stopTalk:(long)iPort;

- (BOOL)setPlaySpeed:(float) speed withPort:(long)iPort;

- (BOOL)resetBuffer:(long)iPort;

- (BOOL)openVoice:(long)iPort;

- (BOOL)closeVoice:(long)iPort;
@end
