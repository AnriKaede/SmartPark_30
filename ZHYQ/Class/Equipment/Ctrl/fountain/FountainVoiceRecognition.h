//
//  FountainVoiceRecognition.h
//  ZHYQ
//
//  Created by 魏唯隆 on 2018/11/23.
//  Copyright © 2018 焦平. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
typedef enum {
    Open1Num = 0,
    Close1Num,
    Open2Num,
    Close2Num,
    Open3Num,
    Close3Num,
    Open4Num,
    Close4Num,
    Open5Num,
    Close5Num,
    NotSupport  // 不支持控制
}FountainControlStyle;
*/
 
@interface FountainVoiceRecognition : NSObject


NS_ASSUME_NONNULL_BEGIN


/**
 语音结果解析

 @param result 语音识别文字结果
 @return 返回控制结果数组，1：开，2：关，0：无效
 */
+ (NSArray *)recognitionResult:(NSString *)result;

@end

NS_ASSUME_NONNULL_END
