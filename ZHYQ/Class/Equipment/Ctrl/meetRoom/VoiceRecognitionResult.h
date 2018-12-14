//
//  VoiceRecognitionResult.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/22.
//  Copyright © 2018 焦平. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    OpenLight = 0,  // 开灯
    CloseLight, // 关灯
    OpenCurtain,    // 开窗帘
    CloseCurtain,   // 关窗帘
    OpenAirCondit,  // 开空调
    CloseAirCondit, // 关空调
    OpenShadow,  // 开投影幕布
    CloseShadow,  // 关投影幕布
    NotSupport  // 不支持控制
}MeetRoomControlStyle;

NS_ASSUME_NONNULL_BEGIN

@interface VoiceRecognitionResult : NSObject

+ (MeetRoomControlStyle)recognitionResult:(NSString *)result;

@end

NS_ASSUME_NONNULL_END
