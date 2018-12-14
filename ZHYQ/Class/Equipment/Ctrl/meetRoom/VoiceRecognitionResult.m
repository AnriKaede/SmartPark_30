//
//  VoiceRecognitionResult.m
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/22.
//  Copyright © 2018 焦平. All rights reserved.
//

#import "VoiceRecognitionResult.h"

@implementation VoiceRecognitionResult

+ (MeetRoomControlStyle)recognitionResult:(NSString *)result {
    /**
     开 灯
     关 灯
     开 空调
     关 空调
     开 纱窗/窗帘
     关 纱窗/窗帘
     开 投影/幕布
     关 投影/幕布
     按以上优先级判断
     */
    
    BOOL isOpen = [result containsString:@"开"];
    BOOL isClose = [result containsString:@"关"];
    
    BOOL isLight = [result containsString:@"灯"];
    
    BOOL isAirCondit = [result containsString:@"空调"];
    
    BOOL isCurtain = [result containsString:@"纱窗"];
    BOOL isCurtain1 = [result containsString:@"纱帘"];
    BOOL isCurtain2 = [result containsString:@"窗帘"];
    BOOL isCurtain3 = [result containsString:@"布帘"];
    
    BOOL isShadow = [result containsString:@"投影"];
    BOOL isShadow2 = [result containsString:@"幕布"];
    
    if(isOpen && !isClose){
        // 开
        if(isLight){
            return OpenLight;
        }else if (isAirCondit) {
            return OpenAirCondit;
        }else if (isCurtain || isCurtain2 || isCurtain1 || isCurtain3) {
            return OpenCurtain;
        }else if (isShadow || isShadow2) {
            return OpenShadow;
        }else {
            return NotSupport;
        }
    }else if (!isOpen && isClose) {
        // 关
        if(isLight){
            return CloseLight;
        }else if (isAirCondit) {
            return CloseAirCondit;
        }else if (isCurtain || isCurtain2 || isCurtain1 || isCurtain3) {
            return CloseCurtain;
        }else if (isShadow || isShadow2) {
            return CloseShadow;
        }else {
            return NotSupport;
        }
    }else {
        return NotSupport;
    }
}

@end
